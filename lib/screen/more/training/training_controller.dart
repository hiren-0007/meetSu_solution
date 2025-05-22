import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/training/assigned_training_response_model.dart';
import 'package:meetsu_solutions/model/training/completed_training_response_model.dart';
import 'package:meetsu_solutions/model/training/trainingDoc/training_doc_response_model.dart';
import 'package:meetsu_solutions/model/training/trainingDoc/training_doc_view_response_model.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/extra/pdf_viewer_screen_assigned_screen.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class TrainingController {
  final ApiService _apiService;

  // State management
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isDocumentLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<String?> successMessage = ValueNotifier<String?>(null);

  // Data management
  final ValueNotifier<List<AssignedTrainingData>> assignedTrainings =
  ValueNotifier<List<AssignedTrainingData>>([]);
  final ValueNotifier<List<CompletedTrainingData>> completedTrainings =
  ValueNotifier<List<CompletedTrainingData>>([]);

  // Private variables
  bool _isDisposed = false;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const Duration _timeoutDuration = Duration(seconds: 30);

  TrainingController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    _initializeWithToken();
  }

  Future<void> _initializeWithToken() async {
    try {
      final token = SharedPrefsService.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        _apiService.client.addAuthToken(token);
        debugPrint('🔑 Token set in API client successfully');
      } else {
        debugPrint('⚠️ No authentication token found');
        throw Exception('Authentication required. Please login again.');
      }
    } catch (e) {
      debugPrint('❌ Error initializing token: $e');
      rethrow;
    }
  }

  Future<void> loadTrainings({bool showLoading = true}) async {
    if (_isDisposed) return;

    if (showLoading) {
      isLoading.value = true;
    }
    _clearMessages();

    try {
      await _initializeWithToken();

      final assignedData = await _loadAssignedTrainings().timeout(_timeoutDuration);
      final completedData = await _loadCompletedTrainings().timeout(_timeoutDuration);

      if (!_isDisposed) {
        assignedTrainings.value = assignedData;
        completedTrainings.value = completedData;

        final totalCount = assignedTrainings.value.length + completedTrainings.value.length;
        if (totalCount > 0) {
          successMessage.value = 'Successfully loaded $totalCount trainings';
        }

        debugPrint('✅ Successfully loaded trainings');
        debugPrint('📚 Assigned: ${assignedTrainings.value.length}');
        debugPrint('✅ Completed: ${completedTrainings.value.length}');
      }

    } catch (e) {
      debugPrint('❌ Error loading trainings: $e');
      if (!_isDisposed) {
        _handleError(e, 'Failed to load trainings');
        // Only load fallback data if it's a network error
        if (_isNetworkError(e)) {
          _loadFallbackData();
        }
      }
    } finally {
      if (!_isDisposed && showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<List<AssignedTrainingData>> _loadAssignedTrainings() async {
    try {
      debugPrint('📥 Fetching assigned trainings...');
      final response = await _apiService.getTrainingAssigned();
      debugPrint('📥 Assigned trainings response received');

      if (response == null) {
        throw Exception('Empty response from server');
      }

      final assignedModel = AssignedTrainingResponseModel.fromJson(response);
      final data = assignedModel.data ?? [];
      debugPrint('📚 Parsed ${data.length} assigned trainings');

      return data;
    } catch (e) {
      debugPrint('❌ Error loading assigned trainings: $e');
      throw Exception('Failed to load assigned trainings: ${_getErrorMessage(e)}');
    }
  }

  Future<List<CompletedTrainingData>> _loadCompletedTrainings() async {
    try {
      debugPrint('📥 Fetching completed trainings...');
      final response = await _apiService.getTrainingCompleted();
      debugPrint('📥 Completed trainings response received');

      if (response == null) {
        throw Exception('Empty response from server');
      }

      final completedModel = CompletedTrainingResponseModel.fromJson(response);
      final data = completedModel.data ?? [];
      debugPrint('✅ Parsed ${data.length} completed trainings');

      return data;
    } catch (e) {
      debugPrint('❌ Error loading completed trainings: $e');
      throw Exception('Failed to load completed trainings: ${_getErrorMessage(e)}');
    }
  }

  void _loadFallbackData() {
    debugPrint('🔄 Loading fallback data due to network issues');
    assignedTrainings.value = [
      AssignedTrainingData(
        trainingId: 1,
        clientName: "Sample Client",
        trainingName: "Safety Training (Demo)",
        docRead: 0,
      ),
    ];
    completedTrainings.value = [
      CompletedTrainingData(
        trainingId: 2,
        clientName: "Demo Client",
        trainingName: "Completed Training (Demo)",
        score: 85,
        document: "sample_document.pdf",
      ),
    ];
    successMessage.value = 'Showing demo data. Please check your connection and retry.';
  }

  Future<void> viewAssignedTraining(BuildContext context, AssignedTrainingData training) async {
    if (_isDisposed || !context.mounted) return;

    try {
      await _showTrainingDetailsDialog(
        context,
        training.trainingName ?? 'Unknown Training',
        training.clientName ?? 'Unknown Client',
        'Assigned Training',
        training.docRead == 1 ? 'Document Read' : 'Not Read',
            () => _startTraining(context, training),
        actionText: 'Start Training',
        statusColor: training.docRead == 1 ? Colors.green : Colors.orange,
      );
    } catch (e) {
      debugPrint('❌ Error viewing assigned training: $e');
      _showErrorSnackBar(context, 'Failed to view training details');
    }
  }

  Future<void> viewCompletedTraining(BuildContext context, CompletedTrainingData training) async {
    if (_isDisposed || !context.mounted) return;

    try {
      await _showTrainingDetailsDialog(
        context,
        training.trainingName ?? 'Unknown Training',
        training.clientName ?? 'Unknown Client',
        'Completed Training',
        'Score: ${training.score ?? 'N/A'}',
        training.document != null
            ? () => _viewCompletedDocument(context, training)
            : null,
        actionText: training.document != null ? 'View Document' : null,
        statusColor: Colors.green,
        additionalInfo: training.document != null ? 'Document Available' : 'No document available',
      );
    } catch (e) {
      debugPrint('❌ Error viewing completed training: $e');
      _showErrorSnackBar(context, 'Failed to view training details');
    }
  }

  Future<void> _startTraining(BuildContext context, AssignedTrainingData training) async {
    if (_isDisposed || !context.mounted) return;

    Navigator.pop(context); // Close dialog
    isDocumentLoading.value = true;

    try {
      debugPrint('🚀 Starting training with ID: ${training.trainingId}');

      // Get training document with retry mechanism
      final docData = await _getTrainingDocument(training.trainingId!);
      final viewData = await _getDocumentView(docData.documentId!);

      // Build PDF URL
      final fullUrl = _buildPdfUrl(viewData.documentPath!);
      debugPrint('📄 Final PDF URL: $fullUrl');

      // Prepare training data
      final Map<String, dynamic> trainingData = {
        'training_id': training.trainingId,
        'document_id': docData.documentId,
        'give_test': viewData.giveTest ?? 0,
        'client_name': training.clientName,
        'training_name': training.trainingName,
        'document_name': docData.name,
      };

      // Navigate to PDF viewer
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreenAssignedScreen(
              pdfUrl: fullUrl,
              trainingData: trainingData,
            ),
          ),
        );

        // Refresh trainings after returning from PDF viewer
        await loadTrainings(showLoading: false);
      }

    } catch (e) {
      debugPrint('❌ Error starting training: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to start training: ${_getErrorMessage(e)}');
      }
    } finally {
      if (!_isDisposed) {
        isDocumentLoading.value = false;
      }
    }
  }

  Future<void> _viewCompletedDocument(BuildContext context, CompletedTrainingData training) async {
    if (_isDisposed || !context.mounted) return;

    Navigator.pop(context); // Close dialog
    isDocumentLoading.value = true;

    try {
      debugPrint('📄 Viewing document for training ID: ${training.trainingId}');

      // Get training document with retry mechanism
      final docData = await _getTrainingDocument(training.trainingId!);
      final viewData = await _getDocumentView(docData.documentId!);

      // Build PDF URL
      final fullUrl = _buildPdfUrl(viewData.documentPath!);
      debugPrint('📄 Final PDF URL: $fullUrl');

      // Navigate to PDF viewer
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              pdfUrl: fullUrl,
              title: training.trainingName ?? 'Training Document',
            ),
          ),
        );
      }

    } catch (e) {
      debugPrint('❌ Error viewing document: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to open document: ${_getErrorMessage(e)}');
      }
    } finally {
      if (!_isDisposed) {
        isDocumentLoading.value = false;
      }
    }
  }

  Future<TrainingDocData> _getTrainingDocument(int trainingId) async {
    TrainingDocData? docData;
    Exception? lastException;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('📤 Getting training document (attempt $attempt/$_maxRetries)');

        final docResponse = await _apiService.trainingDoc({
          'training_id': trainingId.toString()
        }).timeout(_timeoutDuration);

        final docModel = TrainingDocResponseModel.fromJson(docResponse);

        if (docModel.data == null || docModel.data!.isEmpty) {
          throw Exception("No document found for this training");
        }

        docData = docModel.data!.first;
        if (docData.documentId == null) {
          throw Exception("Document ID not found");
        }

        debugPrint('✅ Document retrieved successfully');
        return docData;

      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        debugPrint('⚠️ Attempt $attempt failed: $e');

        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay);
        }
      }
    }

    throw lastException ?? Exception('Failed to get training document after $_maxRetries attempts');
  }

  Future<TrainingDocViewResponseModel> _getDocumentView(int documentId) async {
    TrainingDocViewResponseModel? viewModel;
    Exception? lastException;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('📤 Getting document view (attempt $attempt/$_maxRetries)');

        final viewResponse = await _apiService.trainingDocView({
          'document_id': documentId.toString()
        }).timeout(_timeoutDuration);

        viewModel = TrainingDocViewResponseModel.fromJson(viewResponse);

        if (viewModel.documentPath == null || viewModel.documentPath!.isEmpty) {
          throw Exception("Document path is empty");
        }

        debugPrint('✅ Document view retrieved successfully');
        return viewModel;

      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        debugPrint('⚠️ Attempt $attempt failed: $e');

        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay);
        }
      }
    }

    throw lastException ?? Exception('Failed to get document view after $_maxRetries attempts');
  }

  String _buildPdfUrl(String documentPath) {
    const String baseUrl = 'https://www.meetsusolutions.com';
    final String normalizedPath = documentPath.startsWith('/')
        ? documentPath
        : '/$documentPath';
    return '$baseUrl$normalizedPath'.replaceAll(' ', '%20');
  }

  Future<void> _showTrainingDetailsDialog(
      BuildContext context,
      String trainingName,
      String clientName,
      String type,
      String status,
      VoidCallback? onAction, {
        String? actionText,
        Color? statusColor,
        String? additionalInfo,
      }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trainingName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor ?? Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow("Client:", clientName),
              const SizedBox(height: 12),
              _buildInfoRow("Status:", status),
              if (additionalInfo != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow("Info:", additionalInfo),
              ],
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (onAction != null)
              ValueListenableBuilder<bool>(
                valueListenable: isDocumentLoading,
                builder: (context, loading, child) {
                  return ElevatedButton(
                    onPressed: loading ? null : onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor ?? Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(actionText ?? "Start Training"),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
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
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: () => loadTrainings(),
        ),
      ),
    );
  }

  void _clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  void _handleError(dynamic error, String defaultMessage) {
    String errorMsg;

    if (_isNetworkError(error)) {
      errorMsg = "Network connection error. Please check your internet and try again.";
    } else if (error.toString().contains("timeout")) {
      errorMsg = "Request timed out. Please try again.";
    } else if (error.toString().contains("Authentication")) {
      errorMsg = "Session expired. Please login again.";
    } else if (error.toString().contains("server")) {
      errorMsg = "Server error. Please try again later.";
    } else {
      errorMsg = defaultMessage;
    }

    errorMessage.value = errorMsg;
  }

  String _getErrorMessage(dynamic error) {
    if (_isNetworkError(error)) {
      return "Network connection issue";
    } else if (error.toString().contains("timeout")) {
      return "Request timeout";
    } else if (error.toString().contains("Authentication")) {
      return "Authentication required";
    } else {
      return "Unexpected error occurred";
    }
  }

  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains("connection closed") ||
        errorString.contains("socketexception") ||
        errorString.contains("connection refused") ||
        errorString.contains("no internet") ||
        errorString.contains("network") ||
        errorString.contains("timeout");
  }

  // Refresh methods
  Future<void> refreshTrainings() async {
    await loadTrainings();
  }

  // Get training counts
  int get totalTrainingsCount =>
      assignedTrainings.value.length + completedTrainings.value.length;

  int get pendingTrainingsCount =>
      assignedTrainings.value.where((t) => t.docRead != 1).length;

  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    isLoading.dispose();
    isDocumentLoading.dispose();
    errorMessage.dispose();
    successMessage.dispose();
    assignedTrainings.dispose();
    completedTrainings.dispose();
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    this.title = "Training Document",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh the PDF
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerScreen(
                    pdfUrl: pdfUrl,
                    title: title,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          debugPrint('📄 PDF loaded successfully: ${details.document.pages.count} pages');
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
                    child: Text('Failed to load document: ${details.error}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerScreen(
                      pdfUrl: pdfUrl,
                      title: title,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}