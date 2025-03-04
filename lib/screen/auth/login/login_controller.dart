import 'package:flutter/material.dart';
import 'package:meetsu_solutions/model/auth/login/login_request_model.dart';
import 'package:meetsu_solutions/model/auth/login/login_response_model.dart';
import 'package:meetsu_solutions/screen/auth/signup/signup_screen.dart';
import 'package:meetsu_solutions/screen/home/home_screen.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class LoginController {
  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable states
  final ValueNotifier<bool> obscureText = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // API service
  final ApiService _apiService = ApiService(ApiClient());

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  // Login function
  Future<bool> login(BuildContext context) async {
    try {
      // Set loading state
      isLoading.value = true;
      errorMessage.value = null;

      // Get values from controllers
      final username = emailController.text.trim();
      final password = passwordController.text;

      // Validate input
      if (username.isEmpty || password.isEmpty) {
        errorMessage.value = "Please enter both username and password";
        return false;
      }

      // Create login request model
      final loginRequest = LoginRequestModel(
        username: username,
        password: password,
      );

      // Call API
      final response = await _apiService.loginUser(loginRequest.toJson());

      // Parse response
      final loginResponse = LoginResponseModel.fromJson(response);

      // Check if access token exists
      if (loginResponse.accessToken != null && loginResponse.accessToken!.isNotEmpty) {
        // Store token in SharedPreferences
        await SharedPrefsService.instance.saveLoginResponse(loginResponse);

        // Check if temporary login
        if (loginResponse.isTempLogin == 1) {
          debugPrint("Temporary login detected, user should change password");
        }

        // Navigate to home screen
        if (context.mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen())
          );
        }
        return true;
      } else {
        // Login failed
        errorMessage.value = "Authentication failed. Please check your credentials.";
        return false;
      }
    } catch (e) {
      if (e is HttpException) {
        if (e.statusCode == 401) {
          errorMessage.value = "Invalid username or password";
        } else {
          errorMessage.value = "Server error: ${e.message}";
        }
      } else {
        errorMessage.value = "An error occurred: ${e.toString()}";
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to signup screen
  void navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  // Dispose resources
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    obscureText.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}