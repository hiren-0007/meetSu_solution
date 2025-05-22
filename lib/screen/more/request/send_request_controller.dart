import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/model/request/request_records_model.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// Global navigator key for dialogs
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SendRequestController {
  // Form controllers
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController signatureController = TextEditingController();

  // Signature state
  final ValueNotifier<List<Offset?>> signaturePoints = ValueNotifier<List<Offset?>>([]);
  final ValueNotifier<bool> isTypedSignature = ValueNotifier<bool>(true);

  // Date and UI state
  final ValueNotifier<DateTime> selectedDate = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isSubmitting = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<String?> successMessage = ValueNotifier<String?>(null);

  // Form validation
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showValidation = ValueNotifier<bool>(false);

  // Data management
  final ValueNotifier<List<RequestRecord>> records = ValueNotifier<List<RequestRecord>>([]);

  // Private variables
  final ApiService _apiService;
  final DateFormat _dateFormat = DateFormat('MMM-dd-yyyy');
  bool _isDisposed = false;

  // Constants
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const Duration _timeoutDuration = Duration(seconds: 30);

  SendRequestController(this._apiService) {
    _initializeListeners();
  }

  void _initializeListeners() {
    reasonController.addListener(_validateForm);
    amountController.addListener(_validateForm);
    nameController.addListener(_validateForm);
    signatureController.addListener(_validateForm);
    signaturePoints.addListener(_validateForm);
  }

  void _validateForm() {
    if (_isDisposed) return;

    final hasReason = reasonController.text.trim().isNotEmpty;
    final hasAmount = amountController.text.trim().isNotEmpty;
    final hasName = nameController.text.trim().isNotEmpty;
    final hasSignature = isTypedSignature.value
        ? signatureController.text.trim().isNotEmpty
        : signaturePoints.value.isNotEmpty;

    final isValid = hasReason && hasAmount && hasName && hasSignature;

    if (isFormValid.value != isValid) {
      isFormValid.value = isValid;
    }
  }

  // Enhanced initialization
  Future<void> initialize() async {
    try {
      await refreshRecords();
      debugPrint("✅ SendRequestController initialized successfully");
    } catch (e) {
      debugPrint("❌ Error initializing SendRequestController: $e");
      errorMessage.value = "Failed to initialize. Please try again.";
    }
  }

  String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  Future<void> selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.primaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != selectedDate.value) {
        selectedDate.value = picked;
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      debugPrint("❌ Error selecting date: $e");
    }
  }

  Future<void> refreshRecords() async {
    if (_isDisposed) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception("No authentication token found. Please log in again.");
      }

      _apiService.client.addAuthToken(token);
      debugPrint("🔄 Fetching request records...");

      final response = await _apiService
          .getRequestRecords()
          .timeout(_timeoutDuration);

      debugPrint("📥 Records API Response received");

      final requestRecordsModel = RequestRecordsModel.fromJson(response);
      final recordsList = requestRecordsModel.data ?? [];

      records.value = recordsList;
      debugPrint("✅ Successfully loaded ${recordsList.length} records");

      if (recordsList.isEmpty) {
        successMessage.value = "No request records found";
      }

    } catch (e) {
      debugPrint("❌ Error fetching records: $e");
      _handleError(e, "Failed to fetch records");
      records.value = []; // Clear on error
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  Future<String?> _getAuthToken() async {
    try {
      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }
      return token;
    } catch (e) {
      debugPrint("❌ Error getting auth token: $e");
      return null;
    }
  }

  void _handleError(dynamic error, String defaultMessage) {
    if (_isDisposed) return;

    String errorMsg;

    if (error.toString().contains("Connection") ||
        error.toString().contains("SocketException") ||
        error.toString().contains("timeout")) {
      errorMsg = "Network connection error. Please check your internet and try again.";
    } else if (error.toString().contains("Unauthorized") ||
        error.toString().contains("401")) {
      errorMsg = "Your session has expired. Please log in again.";
      SharedPrefsService.instance.clear();
    } else if (error.toString().contains("authentication")) {
      errorMsg = "Authentication failed. Please log in again.";
    } else {
      errorMsg = defaultMessage;
    }

    errorMessage.value = errorMsg;
  }

  void showPdf(RequestRecord record, BuildContext context) {
    if (record.filepath != null && record.filepath!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnhancedPdfViewerScreen(
            pdfUrl: record.filepath!,
            title: "Request Document",
            record: record,
          ),
        ),
      );
    } else {
      _showErrorSnackBar(context, "PDF file path not found");
    }
  }

  void showRequestDialog(BuildContext context) {
    if (reasonController.text.trim().isEmpty) {
      errorMessage.value = "Please enter a reason for your request";
      return;
    }

    // Clear previous form data
    amountController.clear();
    nameController.clear();
    signatureController.clear();
    signaturePoints.value = [];
    showValidation.value = false;
    errorMessage.value = null;

    // Unfocus any active fields
    FocusScope.of(context).unfocus();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => _buildRequestDialog(context),
      );
    });
  }

  Widget _buildRequestDialog(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDialogHeader(),
                  const SizedBox(height: 24),
                  _buildAmountField(),
                  const SizedBox(height: 20),
                  _buildReasonField(),
                  const SizedBox(height: 20),
                  _buildNameField(),
                  const SizedBox(height: 20),
                  _buildSignatureSection(setState),
                  const SizedBox(height: 24),
                  _buildDialogActions(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.assignment_add,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Deduction Request",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Please fill in all the required details",
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_money, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              "Deduction Amount",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              " *",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _getDialogInputDecoration("Enter Amount (e.g., 100.50)"),
          onChanged: (_) => _validateForm(),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              "Reason",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: reasonController,
          enabled: false,
          decoration: _getDialogInputDecoration("Reason for deduction"),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              "Print Your Name",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              " *",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: nameController,
          textInputAction: TextInputAction.done,
          decoration: _getDialogInputDecoration("Type Your Full Name"),
          onChanged: (_) => _validateForm(),
        ),
      ],
    );
  }

  InputDecoration _getDialogInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: Colors.grey.shade600),
    );
  }
  Widget _buildSignatureSection(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.draw, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              "Signature",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              " *",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: isTypedSignature,
            builder: (context, isTyped, _) {
              return isTyped ? _buildTypedSignature() : _buildDrawnSignature(setState);
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildSignatureActions(setState),
      ],
    );
  }

  Widget _buildTypedSignature() {
    return Center(
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: signatureController,
        builder: (context, value, _) {
          return Text(
            value.text.isEmpty ? "Tap 'Type' to add signature" : value.text,
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'Signature',
              color: value.text.isEmpty ? Colors.grey : Colors.black,
              fontStyle: value.text.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }

  Widget _buildDrawnSignature(StateSetter setState) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          // Fixed: Use details.localPosition directly
          Offset localPosition = details.localPosition;
          signaturePoints.value = List.from(signaturePoints.value)..add(localPosition);
        });
        _validateForm();
      },
      onPanEnd: (details) {
        setState(() {
          signaturePoints.value = List.from(signaturePoints.value)..add(null);
        });
      },
      child: ValueListenableBuilder<List<Offset?>>(
        valueListenable: signaturePoints,
        builder: (context, points, _) {
          return CustomPaint(
            painter: SignaturePainter(points: points),
            size: Size.infinite,
            child: points.isEmpty
                ? const Center(
              child: Text(
                "Tap 'Draw' and sign here",
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildSignatureActions(StateSetter setState) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showTypeSignatureDialog(setState);
              setState(() {
                isTypedSignature.value = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isTypedSignature.value ? Colors.white : Colors.white.withOpacity(0.7),
              foregroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.keyboard, size: 18),
            label: const Text("Type"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                isTypedSignature.value = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: !isTypedSignature.value ? Colors.white : Colors.white.withOpacity(0.7),
              foregroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.draw, size: 18),
            label: const Text("Draw"),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              if (isTypedSignature.value) {
                signatureController.clear();
              } else {
                signaturePoints.value = [];
              }
            });
            _validateForm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.clear, size: 18),
          label: const Text("Clear"),
        ),
      ],
    );
  }

  Widget _buildDialogActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(0, 48),
            ),
            icon: const Icon(Icons.close),
            label: const Text("Cancel"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: isSubmitting,
            builder: (context, submitting, _) {
              return ElevatedButton.icon(
                onPressed: submitting ? null : () => _submitRequest(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(0, 48),
                ),
                icon: submitting
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.send),
                label: Text(submitting ? "Creating..." : "Create"),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTypeSignatureDialog(StateSetter parentSetState) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Type Your Signature"),
        content: TextField(
          controller: signatureController,
          decoration: const InputDecoration(
            hintText: "Enter your signature",
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _validateForm(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              parentSetState(() {}); // Update parent dialog
              _validateForm();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest(BuildContext context) async {
    showValidation.value = true;

    // Validate amount
    double? amount;
    try {
      amount = double.parse(amountController.text.trim());
      if (amount <= 0) {
        _showErrorSnackBar(context, "Amount must be greater than zero");
        return;
      }
    } catch (e) {
      _showErrorSnackBar(context, "Please enter a valid amount");
      return;
    }

    // Validate other fields
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackBar(context, "Please enter your name");
      return;
    }

    if (isTypedSignature.value && signatureController.text.trim().isEmpty) {
      _showErrorSnackBar(context, "Please type your signature");
      return;
    }

    if (!isTypedSignature.value && signaturePoints.value.isEmpty) {
      _showErrorSnackBar(context, "Please draw your signature");
      return;
    }

    await submitRequestWithSignature(context);
  }

  Future<void> submitRequestWithSignature(BuildContext context) async {
    if (_isDisposed) return;

    isSubmitting.value = true;

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception("No authentication token found. Please log in again.");
      }

      _apiService.client.addAuthToken(token);

      final signatureFile = await getSignatureAsFile();
      if (signatureFile == null) {
        throw Exception("Failed to create signature file");
      }

      final amount = double.parse(amountController.text.trim());
      final Map<String, dynamic> requestData = {
        'amount': amount.toString(),
        'reason': reasonController.text.trim(),
      };

      debugPrint("🚀 Submitting request with data: $requestData");

      final response = await _apiService.addDeductionWithSignature(
        requestData,
        signatureFile,
        'sign_name',
      ).timeout(_timeoutDuration);

      debugPrint("📥 Submission response: $response");

      if (response['success'] == true) {
        if (context.mounted) {
          Navigator.pop(context); // Close dialog
          _showSuccessSnackBar(context, "Request submitted successfully!");
        }

        // Reset form and refresh records
        _resetForm();
        await refreshRecords();
      } else {
        final message = response['message'] ?? response['Message'] ?? 'Unknown error occurred';
        throw Exception(message);
      }
    } catch (e) {
      debugPrint("❌ Error submitting request: $e");
      if (context.mounted) {
        _showErrorSnackBar(context, "Failed to submit request: ${e.toString()}");
      }
    } finally {
      if (!_isDisposed) {
        isSubmitting.value = false;
      }
    }
  }

  Future<File?> getSignatureAsFile() async {
    try {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 200);

      // Draw white background
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

      if (isTypedSignature.value) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: signatureController.text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontFamily: 'Signature',
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout(maxWidth: size.width - 40);

        textPainter.paint(
          canvas,
          Offset(
            (size.width - textPainter.width) / 2,
            (size.height - textPainter.height) / 2,
          ),
        );
      } else {
        final paint = Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3.0;

        for (int i = 0; i < signaturePoints.value.length - 1; i++) {
          if (signaturePoints.value[i] != null && signaturePoints.value[i + 1] != null) {
            canvas.drawLine(signaturePoints.value[i]!, signaturePoints.value[i + 1]!, paint);
          } else if (signaturePoints.value[i] != null && signaturePoints.value[i + 1] == null) {
            canvas.drawPoints(PointMode.points, [signaturePoints.value[i]!], paint);
          }
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ImageByteFormat.png);

      if (byteData == null) return null;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      debugPrint("✅ Signature file created: ${file.path}");
      return file;
    } catch (e) {
      debugPrint("❌ Error creating signature file: $e");
      return null;
    }
  }

  void _resetForm() {
    reasonController.clear();
    amountController.clear();
    nameController.clear();
    signatureController.clear();
    signaturePoints.value = [];
    selectedDate.value = DateTime.now();
    showValidation.value = false;
    isFormValid.value = false;
    errorMessage.value = null;
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    reasonController.dispose();
    amountController.dispose();
    nameController.dispose();
    signatureController.dispose();
    isLoading.dispose();
    isSubmitting.dispose();
    errorMessage.dispose();
    successMessage.dispose();
    selectedDate.dispose();
    records.dispose();
    signaturePoints.dispose();
    isTypedSignature.dispose();
    isFormValid.dispose();
    showValidation.dispose();
  }
}

// Enhanced PDF Viewer
class EnhancedPdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;
  final RequestRecord? record;

  const EnhancedPdfViewerScreen({
    super.key,
    required this.pdfUrl,
    this.title = "PDF Document",
    this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        actions: [
          if (record != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'info') {
                  _showRecordInfo(context);
                } else if (value == 'share') {
                  _shareDocument(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text('Record Info'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Document",
            onPressed: () {
              HapticFeedback.lightImpact();
              // Force refresh the PDF
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EnhancedPdfViewerScreen(
                    pdfUrl: pdfUrl,
                    title: title,
                    record: record,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SfPdfViewer.network(
          pdfUrl,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          enableDoubleTapZooming: true,
          canShowPaginationDialog: true,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            debugPrint('📄 PDF loaded successfully: ${details.document.pages.count} pages');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Document loaded (${details.document.pages.count} pages)'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            debugPrint('❌ PDF load failed: ${details.error}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Failed to load document',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${details.error}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'RETRY',
                  textColor: Colors.white,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnhancedPdfViewerScreen(
                          pdfUrl: pdfUrl,
                          title: title,
                          record: record,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          onPageChanged: (PdfPageChangedDetails details) {
            debugPrint('📄 Page changed to: ${details.newPageNumber}');
          },
        ),
      ),
      floatingActionButton: record != null
          ? FloatingActionButton(
        onPressed: () => _showRecordInfo(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        tooltip: "Record Information",
        child: const Icon(Icons.info_outline),
      )
          : null,
    );
  }

  void _showRecordInfo(BuildContext context) {
    if (record == null) return;

    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.assignment, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Request Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildInfoCard('Request ID', record!.id ?? 'N/A', Icons.tag),
              const SizedBox(height: 12),
              _buildInfoCard('Amount', record!.amount ?? '0.00', Icons.attach_money),
              const SizedBox(height: 12),
              _buildInfoCard('Reason', record!.reason ?? 'N/A', Icons.description),
              const SizedBox(height: 12),
              _buildInfoCard('Date', record!.date ?? 'N/A', Icons.calendar_today),
              const SizedBox(height: 12),
              _buildInfoCard('Created', record!.createdDate ?? 'N/A', Icons.access_time),
              if (record!.modifiedDate != null && record!.modifiedDate!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoCard('Modified', record!.modifiedDate!, Icons.edit),
              ],
              if (record!.filename != null && record!.filename!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoCard('Filename', record!.filename!, Icons.file_present),
              ],
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _shareDocument(context);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareDocument(BuildContext context) {
    HapticFeedback.lightImpact();
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.share, color: Colors.white),
            SizedBox(width: 8),
            Text('Share functionality coming soon!'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Enhanced Signature Painter with smooth drawing
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    // Signature
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    Path path = Path();
    bool isNewStroke = true;

    for (int i = 0; i < points.length; i++) {
      if (points[i] == null) {
        isNewStroke = true;
        continue;
      }

      if (isNewStroke) {
        path.moveTo(points[i]!.dx, points[i]!.dy);
        isNewStroke = false;
      } else {
        if (i > 0 && points[i - 1] != null) {
          // Smooth line drawing
          final p1 = points[i - 1]!;
          final p2 = points[i]!;

          // Simple smoothing
          final cp1x = p1.dx + (p2.dx - p1.dx) * 0.5;
          final cp1y = p1.dy + (p2.dy - p1.dy) * 0.5;

          path.quadraticBezierTo(cp1x, cp1y, p2.dx, p2.dy);
        } else {
          path.lineTo(points[i]!.dx, points[i]!.dy);
        }
      }
    }

    canvas.drawPath(path, paint);

    // Draw individual points for single taps
    final pointPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      if (points[i] != null &&
          (i == points.length - 1 || points[i + 1] == null) &&
          (i == 0 || points[i - 1] == null)) {
        canvas.drawCircle(points[i]!, 1.5, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => oldDelegate.points != points;
}

// Utility extension for better signature handling
extension SignatureUtils on SendRequestController {
  bool get hasValidSignature {
    if (isTypedSignature.value) {
      return signatureController.text.trim().isNotEmpty;
    } else {
      return signaturePoints.value.any((point) => point != null);
    }
  }

  void clearSignature() {
    if (isTypedSignature.value) {
      signatureController.clear();
    } else {
      signaturePoints.value = [];
    }
    _validateForm();
  }

  String get signaturePreview {
    if (isTypedSignature.value) {
      final text = signatureController.text.trim();
      return text.isEmpty ? "No signature" : text;
    } else {
      final pointCount = signaturePoints.value.where((p) => p != null).length;
      return pointCount > 0 ? "Drawn signature ($pointCount points)" : "No signature";
    }
  }
}