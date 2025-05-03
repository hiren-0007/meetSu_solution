import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetsu_solutions/model/request/request_records_model.dart';
import 'package:meetsu_solutions/screen/more/training/training_controller.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';

class SendRequestController {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final ValueNotifier<List<Offset?>> signaturePoints =
  ValueNotifier<List<Offset?>>([]);
  final ValueNotifier<bool> isTypedSignature = ValueNotifier<bool>(true);
  final TextEditingController signatureController = TextEditingController();

  final ValueNotifier<DateTime> selectedDate =
  ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  // Change RequestRecord to Data
  final ValueNotifier<List<RequestRecord>> records =
  ValueNotifier<List<RequestRecord>>([]);

  final DateFormat _dateFormat = DateFormat('MMM-dd-yyyy');

  final ApiService _apiService;

  SendRequestController(this._apiService);

  void initialize() {
    refreshRecords();
  }

  String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  // Updated refreshRecords to use RequestRecordsModel
  void refreshRecords() async {
    isLoading.value = true;

    try {
      final token = SharedPrefsService.instance.getAccessToken();
      debugPrint("📱 Token for records: ${token?.isEmpty == true ? 'Empty' : 'Available'}");

      if (token == null || token.isEmpty) {
        errorMessage.value = "No authentication token found. Please log in again.";
        records.value = []; // Clear existing records
        isLoading.value = false;
        return;
      }

      _apiService.client.addAuthToken(token);
      debugPrint("🔄 Fetching records from API...");

      final response = await _apiService.getRequestRecords();
      debugPrint("📥 Records API Response: $response");

      // Parse the response using RequestRecordsModel
      final requestRecordsModel = RequestRecordsModel.fromJson(response);
      debugPrint("📊 Number of records: ${requestRecordsModel.data?.length ?? 0}");

      if (requestRecordsModel.data != null) {
        records.value = requestRecordsModel.data!;
        debugPrint("✅ Successfully loaded ${requestRecordsModel.data!.length} records");
      } else {
        records.value = [];
        debugPrint("⚠️ No data in API response");
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;

      String errorMsg;
      if (e.toString().contains("Connection closed") ||
          e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused") ||
          e.toString().contains("Connection timeout")) {
        errorMsg = "Network connection error. Please check your internet and try again.";
      } else if (e.toString().contains("Unauthorized") ||
          e.toString().contains("401")) {
        await SharedPrefsService.instance.clear();
        errorMsg = "Your session has expired. Please log in again.";
      } else {
        errorMsg = "Failed to fetch records: ${e.toString()}";
      }

      errorMessage.value = errorMsg;
      records.value = []; // Clear existing records on error

      debugPrint("❌ Error fetching records: $e");
      debugPrint("❌ Stack trace: ${StackTrace.current}");
    }
  }

  void showPdf(RequestRecord record, BuildContext context) {
    if (record.filepath != null && record.filepath!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(pdfUrl: record.filepath!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PDF file path not found"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showRequestDialog(BuildContext context) {
    errorMessage.value = null;

    if (reasonController.text.isEmpty) {
      errorMessage.value = "Please enter a reason for your request";
      return;
    }

    amountController.clear();
    nameController.clear();
    signatureController.clear();
    signaturePoints.value = [];

    // Unfocus any active fields
    FocusScope.of(context).unfocus();

    // Add a small delay to prevent focus issues
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Deduction Amount",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Enter Amount",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Reason",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: reasonController,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: "Enter Reason",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Print Your name",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: "Type Your Name Here",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Review your signature",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ValueListenableBuilder<bool>(
                              valueListenable: isTypedSignature,
                              builder: (context, isTyped, _) {
                                if (isTyped) {
                                  return Center(
                                    child: Text(
                                      signatureController.text,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontFamily: 'Signature',
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                } else {
                                  return GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        RenderBox renderBox = context
                                            .findRenderObject() as RenderBox;
                                        Offset localPosition =
                                        renderBox.globalToLocal(
                                            details.globalPosition);
                                        signaturePoints.value =
                                        List.from(signaturePoints.value)
                                          ..add(localPosition);
                                      });
                                    },
                                    onPanEnd: (details) {
                                      setState(() {
                                        signaturePoints.value =
                                        List.from(signaturePoints.value)
                                          ..add(null);
                                      });
                                    },
                                    child: CustomPaint(
                                      painter: SignaturePainter(
                                        points: signaturePoints.value,
                                      ),
                                      size: Size.infinite,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        isTypedSignature.value = true;
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title:
                                            const Text("Type Your Signature"),
                                            content: TextField(
                                              controller: signatureController,
                                              decoration: const InputDecoration(
                                                hintText: "Enter your signature",
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "Type",
                                      style: TextStyle(color: Color(0xFF1565C0)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        isTypedSignature.value = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "Draw",
                                      style: TextStyle(color: Color(0xFF1565C0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 4, right: 4, bottom: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (isTypedSignature.value) {
                                      signatureController.clear();
                                    } else {
                                      signaturePoints.value = [];
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Clear",
                                  style: TextStyle(color: Color(0xFF1565C0)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.only(top: 12, bottom: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    minimumSize: const Size(100, 40),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();

                                    if (amountController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                            Text("Please enter an amount")),
                                      );
                                      return;
                                    }

                                    if (nameController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                            Text("Please enter your name")),
                                      );
                                      return;
                                    }

                                    if (isTypedSignature.value &&
                                        signatureController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Please type your signature")),
                                      );
                                      return;
                                    }

                                    if (!isTypedSignature.value &&
                                        signaturePoints.value.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Please draw your signature")),
                                      );
                                      return;
                                    }

                                    // Don't close the dialog immediately
                                    // Navigator.pop(context);

                                    // Submit request and handle navigation
                                    submitRequestWithSignature(context).then((_) {
                                      // Only close dialog after successful submission
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    minimumSize: const Size(100, 40),
                                  ),
                                  child: const Text(
                                    "Create",
                                    style: TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  Future<File?> getSignatureAsFile() async {
    try {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const Size(300, 150);

      if (isTypedSignature.value) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: signatureController.text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'Signature',
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout(maxWidth: size.width);

        final bgPaint = Paint()..color = Colors.white;
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

        textPainter.paint(
            canvas,
            Offset((size.width - textPainter.width) / 2,
                (size.height - textPainter.height) / 2));
      } else {
        final paint = Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3.0;

        final bgPaint = Paint()..color = Colors.white;
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

        for (int i = 0; i < signaturePoints.value.length - 1; i++) {
          if (signaturePoints.value[i] != null &&
              signaturePoints.value[i + 1] != null) {
            canvas.drawLine(signaturePoints.value[i]!,
                signaturePoints.value[i + 1]!, paint);
          } else if (signaturePoints.value[i] != null &&
              signaturePoints.value[i + 1] == null) {
            canvas.drawPoints(
                PointMode.points, [signaturePoints.value[i]!], paint);
          }
        }
      }

      final picture = recorder.endRecording();
      final img =
      await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ImageByteFormat.png);

      if (byteData == null) return null;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/signature.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file;
    } catch (e) {
      debugPrint("Error creating signature file: $e");
      return null;
    }
  }

  Future<void> submitRequestWithSignature(BuildContext context) async {
    double? amount;
    try {
      amount = double.parse(amountController.text);
      if (amount <= 0) {
        errorMessage.value = "Amount must be greater than zero";
        return;
      }
    } catch (e) {
      errorMessage.value = "Please enter a valid amount";
      return;
    }

    isLoading.value = true;

    try {
      final token = SharedPrefsService.instance.getAccessToken();
      debugPrint("📱 Token retrieved: ${token?.isEmpty == true ? 'Empty' : 'Available'}");

      if (token == null || token.isEmpty) {
        errorMessage.value =
        "No authentication token found. Please log in again.";
        isLoading.value = false;
        return;
      }

      _apiService.client.addAuthToken(token);
      debugPrint("🔑 Auth token added to API client");

      final signatureFile = await getSignatureAsFile();
      if (signatureFile == null) {
        errorMessage.value = "Failed to create signature file";
        isLoading.value = false;
        return;
      }
      debugPrint("✍️ Signature file created: ${signatureFile.path}");

      final Map<String, dynamic> requestData = {
        'amount': amount.toString(),
        'reason': reasonController.text,
      };
      debugPrint("📤 Request data: $requestData");

      // Log just before the API call
      debugPrint("🚀 Making API call to addDeductionWithSignature...");

      final response = await _apiService.addDeductionWithSignature(
          requestData, signatureFile, 'sign_name');

      // Log the response immediately after receiving it
      debugPrint("📥 API Response: $response");
      debugPrint("📥 Response type: ${response.runtimeType}");

      // Log specific response fields
      debugPrint("📊 Response success: ${response['success']}");
      debugPrint("📊 Response message: ${response['message'] ?? response['Message']}");
      debugPrint("📊 Response id: ${response['id']}");

      isLoading.value = false;

      // Handle success response properly
      if (response['success'] == true) {
        // Show success SnackBar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Request submitted successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Refresh records after successful submission
        refreshRecords();

        // Clear all form fields
        reasonController.clear();
        amountController.clear();
        nameController.clear();
        signatureController.clear();
        signaturePoints.value = [];
        selectedDate.value = DateTime.now();
      } else {
        final message = response['message'] ??
            response['Message'] ??
            'Unknown error occurred';
        errorMessage.value = message;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $message"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      isLoading.value = false;

      // Log the error details
      debugPrint("❌ Error occurred: $e");
      debugPrint("❌ Error stack trace: ${StackTrace.current}");

      String errorMsg;
      if (e.toString().contains("Connection closed") ||
          e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused") ||
          e.toString().contains("Connection timeout")) {
        errorMsg =
        "Network connection error. Please check your internet and try again.";
      } else if (e.toString().contains("Unauthorized") ||
          e.toString().contains("401")) {
        errorMsg = "Your session has expired. Please log in again.";
      } else {
        errorMsg = "Failed to submit request: ${e.toString()}";
      }

      errorMessage.value = errorMsg;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $errorMsg"),
            backgroundColor: Colors.red,
          ),
        );
      }

      debugPrint("❌ Error submitting request: $e");
    }
  }

  void dispose() {
    reasonController.dispose();
    amountController.dispose();
    nameController.dispose();
    signatureController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    selectedDate.dispose();
    records.dispose();
    signaturePoints.dispose();
    isTypedSignature.dispose();
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) =>
      oldDelegate.points != points;
}