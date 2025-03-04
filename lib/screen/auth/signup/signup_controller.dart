import 'package:flutter/material.dart';

class SignupController {
  // Text controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Observable states
  final ValueNotifier<bool> obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> obscureConfirmPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  // Validate form fields
  String? _validateFields() {
    if (firstNameController.text.trim().isEmpty) {
      return "First name is required";
    }

    if (lastNameController.text.trim().isEmpty) {
      return "Last name is required";
    }

    if (usernameController.text.trim().isEmpty) {
      return "Username is required";
    }

    if (passwordController.text.isEmpty) {
      return "Password is required";
    }

    if (confirmPasswordController.text.isEmpty) {
      return "Please confirm your password";
    }

    if (passwordController.text != confirmPasswordController.text) {
      return "Passwords do not match";
    }

    // Add additional validation as needed
    if (passwordController.text.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  // Signup function
  Future<bool> signup() async {
    try {
      // Set loading state
      isLoading.value = true;
      errorMessage.value = null;

      // Validate input
      final validationError = _validateFields();
      if (validationError != null) {
        errorMessage.value = validationError;
        return false;
      }

      // Here you would typically make an API call to your registration service
      // For example:
      // final response = await authService.register(
      //   firstName: firstNameController.text.trim(),
      //   lastName: lastNameController.text.trim(),
      //   username: usernameController.text.trim(),
      //   password: passwordController.text
      // );

      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 2));

      // For this example, we'll simulate a successful registration
      return true;
    } catch (e) {
      // Handle errors
      errorMessage.value = "An error occurred: ${e.toString()}";
      return false;
    } finally {
      // Reset loading state
      isLoading.value = false;
    }
  }

  // Navigate to login screen
  void navigateToLogin(BuildContext context) {
    // Navigator.pop or pushReplacement depending on your navigation structure
    Navigator.pop(context);
  }

  // Dispose resources
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    obscurePassword.dispose();
    obscureConfirmPassword.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}