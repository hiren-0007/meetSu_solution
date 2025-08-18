import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ContactController {
  // Dependencies
  final ApiService _apiService;

  // Form management
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController queryController = TextEditingController();

  // State management
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<String?> successMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showValidation = ValueNotifier<bool>(false);

  // Form state tracking
  final ValueNotifier<int> subjectCharCount = ValueNotifier<int>(0);
  final ValueNotifier<int> queryCharCount = ValueNotifier<int>(0);

  // Private variables
  bool _isDisposed = false;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const Duration _timeoutDuration = Duration(seconds: 30);

  // Validation constants
  static const int _minSubjectLength = 1;
  static const int _maxSubjectLength = 100;
  static const int _minQueryLength = 1;
  static const int _maxQueryLength = 500;

  ContactController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient());

  // Enhanced validation methods
  String? validateSubject(String? value) {
    if (!showValidation.value) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Subject is required';
    }

    final trimmedLength = value.trim().length;
    if (trimmedLength < _minSubjectLength) {
      return 'Subject must be at least $_minSubjectLength characters';
    }
    if (trimmedLength > _maxSubjectLength) {
      return 'Subject must not exceed $_maxSubjectLength characters';
    }

    return null;
  }

  String? validateQuery(String? value) {
    if (!showValidation.value) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Query is required';
    }

    final trimmedLength = value.trim().length;
    if (trimmedLength < _minQueryLength) {
      return 'Query must be at least $_minQueryLength characters';
    }
    if (trimmedLength > _maxQueryLength) {
      return 'Query must not exceed $_maxQueryLength characters';
    }

    return null;
  }

  void validateForm() {
    if (_isDisposed) return;

    final isValid = _isFormCurrentlyValid();
    if (isFormValid.value != isValid) {
      isFormValid.value = isValid;
    }
  }

  bool _isFormCurrentlyValid() {
    final subject = subjectController.text.trim();
    final query = queryController.text.trim();

    return subject.length >= _minSubjectLength &&
        subject.length <= _maxSubjectLength &&
        query.length >= _minQueryLength &&
        query.length <= _maxQueryLength;
  }

  void _updateCharCounts() {
    if (_isDisposed) return;

    subjectCharCount.value = subjectController.text.length;
    queryCharCount.value = queryController.text.length;
  }

  void clearMessages() {
    if (_isDisposed) return;

    errorMessage.value = null;
    successMessage.value = null;
  }

  Future<bool> submitForm(BuildContext context) async {
    if (_isDisposed || !context.mounted) return false;

    // Show validation errors
    showValidation.value = true;

    // Clear previous messages
    clearMessages();

    // Validate form
    if (!formKey.currentState!.validate()) {
      errorMessage.value = "Please fix the errors above";
      return false;
    }

    // Check if already loading
    if (isLoading.value) return false;

    isLoading.value = true;

    try {
      // Check authentication
      final token = await _getAuthToken();
      if (token == null) {
        throw const AuthenticationException("Please log in to continue");
      }

      // Prepare data
      final data = _prepareFormData();
      debugPrint("📤 Submitting contact form with ${data.length} fields");

      // Submit with retry and timeout
      final response = await _submitWithRetry(data, token);

      if (_handleResponse(response, context)) {
        await _resetForm();
        return true;
      }

      return false;
    } catch (e) {
      _handleError(e);
      return false;
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
      debugPrint("🔑 Authentication token retrieved");
      return token;
    } catch (e) {
      debugPrint("❌ Error getting auth token: $e");
      return null;
    }
  }

  Map<String, String> _prepareFormData() {
    final data = {
      "subject": subjectController.text.trim(),
      "query": queryController.text.trim(),
    };

    // Add metadata for debugging
    debugPrint("📝 Form data prepared:");
    debugPrint("  - Subject length: ${data['subject']!.length}");
    debugPrint("  - Query length: ${data['query']!.length}");

    return data;
  }

  Future<Map<String, dynamic>> _submitWithRetry(
      Map<String, String> data,
      String token
      ) async {
    _apiService.client.addAuthToken(token);

    Exception? lastException;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint("📤 Submission attempt $attempt/$_maxRetries");

        final response = await _apiService
            .submitContactForm(data)
            .timeout(_timeoutDuration);

        debugPrint("✅ Submission successful on attempt $attempt");
        return response;

      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        debugPrint("⚠️ Attempt $attempt failed: $e");

        if (_isAuthError(e)) {
          throw const AuthenticationException("Session expired. Please log in again.");
        }

        if (_isValidationError(e)) {
          throw Exception("Invalid data submitted. Please check your inputs.");
        }

        // Wait before retry (except on last attempt)
        if (attempt < _maxRetries) {
          final delay = Duration(seconds: _retryDelay.inSeconds * attempt);
          debugPrint("⏱️ Waiting ${delay.inSeconds}s before retry...");
          await Future.delayed(delay);
        }
      }
    }

    throw lastException ?? Exception("Failed after $_maxRetries attempts");
  }

  bool _isAuthError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains("401") ||
        errorStr.contains("unauthorized") ||
        errorStr.contains("authentication");
  }

  bool _isValidationError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains("400") ||
        errorStr.contains("validation") ||
        errorStr.contains("invalid");
  }

  bool _handleResponse(Map<String, dynamic> response, BuildContext context) {
    debugPrint("📥 Response received: ${response['success']}");

    if (response['success'] == true) {
      final message = response['Message'] ?? 'Your query has been submitted successfully!';
      successMessage.value = message;

      if (context.mounted) {
        _showSuccessMessage(context, message);
      }
      return true;
    } else {
      final errorMsg = response['Message'] ?? "Failed to submit contact form";
      throw Exception(errorMsg);
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Success!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _handleError(dynamic error) {
    if (_isDisposed) return;

    String errorMsg;

    if (error is AuthenticationException) {
      errorMsg = error.message;
    } else if (_isNetworkError(error)) {
      errorMsg = "Network connection error. Please check your internet and try again.";
    } else if (error.toString().contains("timeout")) {
      errorMsg = "Request timed out. Please try again.";
    } else if (error.toString().contains("server") || error.toString().contains("500")) {
      errorMsg = "Server error. Please try again later.";
    } else if (error.toString().contains("validation") || error.toString().contains("400")) {
      errorMsg = "Invalid data submitted. Please check your inputs.";
    } else {
      errorMsg = "Failed to submit your query. Please try again.";
    }

    errorMessage.value = errorMsg;
    debugPrint("❌ Contact form submission error: $error");
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

  Future<void> _resetForm() async {
    if (_isDisposed) return;

    debugPrint("🔄 Resetting contact form");

    subjectController.clear();
    queryController.clear();
    isFormValid.value = false;
    showValidation.value = false;
    subjectCharCount.value = 0;
    queryCharCount.value = 0;

    await Future.delayed(const Duration(seconds: 1));
    if (!_isDisposed) {
      clearMessages();
    }
  }

  void initListeners() {
    subjectController.addListener(() {
      validateForm();
      _updateCharCounts();
      if (errorMessage.value != null) {
        clearMessages();
      }
    });

    queryController.addListener(() {
      validateForm();
      _updateCharCounts();
      if (errorMessage.value != null) {
        clearMessages();
      }
    });
  }

  // Utility methods
  double get subjectProgress =>
      (subjectController.text.length / _maxSubjectLength).clamp(0.0, 1.0);

  double get queryProgress =>
      (queryController.text.length / _maxQueryLength).clamp(0.0, 1.0);

  bool get hasMinimumSubjectLength =>
      subjectController.text.trim().length >= _minSubjectLength;

  bool get hasMinimumQueryLength =>
      queryController.text.trim().length >= _minQueryLength;

  // Form field helpers
  Color getSubjectFieldColor() {
    if (subjectController.text.isEmpty) return Colors.grey;
    if (hasMinimumSubjectLength) return Colors.green;
    return Colors.orange;
  }

  Color getQueryFieldColor() {
    if (queryController.text.isEmpty) return Colors.grey;
    if (hasMinimumQueryLength) return Colors.green;
    return Colors.orange;
  }

  void dispose() {
    if (_isDisposed) return;

    debugPrint("🗑️ Disposing contact controller");
    _isDisposed = true;

    subjectController.dispose();
    queryController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    successMessage.dispose();
    isFormValid.dispose();
    showValidation.dispose();
    subjectCharCount.dispose();
    queryCharCount.dispose();
  }
}

// Enhanced exception classes
class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => message;
}