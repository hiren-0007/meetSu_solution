import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/c_home/clint_home_screen.dart';
import 'package:meetsu_solutions/model/auth/login/login_request_model.dart';
import 'package:meetsu_solutions/model/auth/login/login_response_model.dart';
import 'package:meetsu_solutions/screen/auth/signup/signup_screen.dart';
import 'package:meetsu_solutions/screen/home/home_screen.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/map/LocationService.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/services/firebase/firebase_messaging_service.dart';

class LoginController {
  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State notifiers
  final ValueNotifier<bool> obscureText = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Services - using lazy initialization
  late final ApiService _apiService = ApiService(ApiClient());
  late final LocationService _locationService = LocationService();
  late final FirebaseMessagingService _firebaseMessagingService = FirebaseMessagingService();

  // Constants for error messages
  static const String _emptyFieldsError = "Please enter both username and password";
  static const String _authFailedError = "Authentication failed. Please check your credentials.";
  static const String _invalidCredentialsError = "Invalid username or password";

  /// Toggles password visibility
  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  /// Performs login operation
  Future<bool> login(BuildContext context) async {
    if (!_validateInputs()) return false;

    _setLoadingState(true);

    try {
      final loginRequest = _createLoginRequest();
      final response = await _apiService.loginUser(loginRequest.toJson());
      final loginResponse = LoginResponseModel.fromJson(response);

      if (!_isValidLoginResponse(loginResponse)) {
        _setError(_authFailedError);
        return false;
      }

      await _handleSuccessfulLogin(loginResponse, context);
      return true;

    } catch (e) {
      _handleLoginError(e);
      return false;
    } finally {
      _setLoadingState(false);
    }
  }

  /// Validates user inputs
  bool _validateInputs() {
    final username = emailController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _setError(_emptyFieldsError);
      return false;
    }

    _clearError();
    return true;
  }

  /// Creates login request model
  LoginRequestModel _createLoginRequest() {
    return LoginRequestModel(
      username: emailController.text.trim(),
      password: passwordController.text,
    );
  }

  /// Validates login response
  bool _isValidLoginResponse(LoginResponseModel response) {
    return response.accessToken != null && response.accessToken!.isNotEmpty;
  }

  /// Handles successful login
  Future<void> _handleSuccessfulLogin(
      LoginResponseModel loginResponse,
      BuildContext context,
      ) async {

    // 🔥 IMPORTANT: Save login type FIRST before other operations
    if (loginResponse.login != null && loginResponse.login!.isNotEmpty) {
      await SharedPrefsService.instance.saveLoginType(loginResponse.login!);
    } else {
      print("⚠️ Warning: Login type is null or empty in response");
    }

    // Save other login data
    await Future.wait([
      SharedPrefsService.instance.saveLoginResponse(loginResponse),
      SharedPrefsService.instance.saveUsername(emailController.text.trim()),
    ]);

    // Send Firebase token
    await _firebaseMessagingService.sendTokenToServerAfterLogin();

    // Navigate to appropriate screen based on login type
    if (context.mounted) {
      await _requestLocationPermission(context);
      await _navigateBasedOnLoginType(context, loginResponse.login);
    }
  }

  /// Handles login errors
  void _handleLoginError(dynamic error) {
    if (error is HttpException) {
      _setError(error.statusCode == 401
          ? _invalidCredentialsError
          : "Server error: ${error.message}");
    } else {
      _setError("An error occurred: ${error.toString()}");
    }
  }

  /// Requests location permission
  Future<void> _requestLocationPermission(BuildContext context) async {
    try {
      await _locationService.handleLocationPermission(context);
    } catch (e) {
      debugPrint("Location permission error: $e");
    }
  }

  /// Navigates based on login type
  Future<void> _navigateBasedOnLoginType(BuildContext context, String? loginType) async {
    Widget destinationScreen;


    switch (loginType?.toLowerCase()) {
      case 'applicant':
        destinationScreen = const HomeScreen();
        break;
      case 'client':
        destinationScreen = const ClientHomeScreen();
        break;
      default:
        destinationScreen = const HomeScreen();
        break;
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destinationScreen),
    );
  }

  /// Navigates to signup screen
  void navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  /// Helper methods for state management
  void _setLoadingState(bool loading) {
    isLoading.value = loading;
  }

  void _setError(String error) {
    errorMessage.value = error;
  }

  void _clearError() {
    errorMessage.value = null;
  }

  /// Disposes all resources
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    obscureText.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}

/// Custom exception for HTTP errors
class HttpException implements Exception {
  final int statusCode;
  final String message;

  const HttpException(this.statusCode, this.message);

  @override
  String toString() => 'HttpException: $statusCode - $message';
}