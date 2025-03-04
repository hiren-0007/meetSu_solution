import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'dart:io';

class ContactController {
  // API Service
  final ApiService _apiService;

  // Text controllers for input fields
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController queryController = TextEditingController();

  // ValueNotifiers for reactive state management
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);

  // Constructor
  ContactController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient());

  // Method to check if form is valid
  void validateForm() {
    final isValid = subjectController.text.trim().isNotEmpty &&
        queryController.text.trim().isNotEmpty;
    isFormValid.value = isValid;
  }

  // Method to submit the contact form
  Future<bool> submitForm(BuildContext context) async {
    // Reset error message
    errorMessage.value = null;

    // Validate form again
    validateForm();
    if (!isFormValid.value) {
      errorMessage.value = "Please fill all required fields";
      return false;
    }

    // Show loading indicator
    isLoading.value = true;

    try {
      // Get user token from Shared Preferences
      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      // Add Authorization Token to API Client
      _apiService.client.addAuthToken(token);

      // Prepare data for API call
      final Map<String, String> data = {
        "subject": subjectController.text.trim(),
        "query": queryController.text.trim()
      };

      debugPrint("📤 Sending contact form data: $data");

      // Make API Call with retry logic
      Map<String, dynamic> response;
      try {
        response = await _apiService.submitContactForm(data);
      } catch (e) {
        // First retry
        debugPrint("⚠️ First attempt failed, retrying...");
        await Future.delayed(const Duration(seconds: 2));
        response = await _apiService.submitContactForm(data);
      }

      debugPrint("📥 Received response: $response");

      // Check response
      if (response['success'] == true) {
        // Reset loading state
        isLoading.value = false;

        // Clear form after successful submission
        subjectController.clear();
        queryController.clear();
        isFormValid.value = false;

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['Message'] ?? 'Your query has been submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        return true;
      } else {
        // Handle failed response
        throw Exception(response['Message'] ?? "Failed to submit contact form");
      }
    } catch (e) {
      // Handle error
      isLoading.value = false;

      // Provide user-friendly error message based on error type
      String errorMsg;
      if (e.toString().contains("Connection closed") ||
          e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused") ||
          e.toString().contains("Connection timeout")) {
        errorMsg = "Network connection error. Please check your internet and try again.";
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

  // Method to navigate back
  void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  // Listen to text changes for validation
  void initListeners() {
    subjectController.addListener(validateForm);
    queryController.addListener(validateForm);
  }

  // Clean up resources
  void dispose() {
    subjectController.dispose();
    queryController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    isFormValid.dispose();
  }
}