import 'package:flutter/material.dart';

class SignupController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final ValueNotifier<bool> obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> obscureConfirmPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

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

    if (passwordController.text.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  Future<bool> signup() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final validationError = _validateFields();
      if (validationError != null) {
        errorMessage.value = validationError;
        return false;
      }

      await Future.delayed(const Duration(seconds: 2));

      return true;
    } catch (e) {
      errorMessage.value = "An error occurred: ${e.toString()}";
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pop(context);
  }

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
