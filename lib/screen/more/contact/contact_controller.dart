import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ContactController {
  final ApiService _apiService;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController queryController = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);

  ContactController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient());

  void validateForm() {
    final isValid = subjectController.text.trim().isNotEmpty &&
        queryController.text.trim().isNotEmpty;
    isFormValid.value = isValid;
  }

  Future<bool> submitForm(BuildContext context) async {
    errorMessage.value = null;

    validateForm();
    if (!isFormValid.value) {
      errorMessage.value = "Please fill all required fields";
      return false;
    }

    isLoading.value = true;

    try {
      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      _apiService.client.addAuthToken(token);

      final Map<String, String> data = {
        "subject": subjectController.text.trim(),
        "query": queryController.text.trim()
      };

      debugPrint("📤 Sending contact form data: $data");

      Map<String, dynamic> response;
      try {
        response = await _apiService.submitContactForm(data);
      } catch (e) {
        debugPrint("⚠️ First attempt failed, retrying...");
        await Future.delayed(const Duration(seconds: 2));
        response = await _apiService.submitContactForm(data);
      }

      debugPrint("📥 Received response: $response");

      if (response['success'] == true) {
        isLoading.value = false;

        subjectController.clear();
        queryController.clear();
        isFormValid.value = false;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['Message'] ??
                  'Your query has been submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        return true;
      } else {
        throw Exception(response['Message'] ?? "Failed to submit contact form");
      }
    } catch (e) {
      isLoading.value = false;

      String errorMsg;
      if (e.toString().contains("Connection closed") ||
          e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused") ||
          e.toString().contains("Connection timeout")) {
        errorMsg =
            "Network connection error. Please check your internet and try again.";
      } else if (e.toString().contains("No authentication token found")) {
        errorMsg = "You need to log in again to continue.";
      } else {
        errorMsg = "Failed to submit your query. Please try again later.";
      }

      errorMessage.value = errorMsg;
      debugPrint("❌ Error submitting contact form: $e");
      return false;
    }
  }

  void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  void initListeners() {
    subjectController.addListener(validateForm);
    queryController.addListener(validateForm);
  }

  void dispose() {
    subjectController.dispose();
    queryController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    isFormValid.dispose();
  }
}
