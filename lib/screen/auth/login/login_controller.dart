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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> obscureText = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  late final ApiService _apiService = ApiService(ApiClient());
  late final LocationService _locationService = LocationService();
  late final FirebaseMessagingService _firebaseMessagingService = FirebaseMessagingService();

  bool _isDisposed = false;

  static const String _emptyFieldsError = "Please enter both username and password";
  static const String _authFailedError = "Authentication failed. Please check your credentials.";
  static const String _invalidCredentialsError = "Invalid username or password";

  void togglePasswordVisibility() {
    if (_isDisposed) return;
    obscureText.value = !obscureText.value;
  }

  Future<bool> login(BuildContext context) async {
    if (_isDisposed || !context.mounted) return false;

    if (!_validateInputs()) return false;

    _setLoadingState(true);

    try {
      final loginRequest = _createLoginRequest();
      final response = await _apiService.loginUser(loginRequest.toJson());

      if (_isDisposed || !context.mounted) return false;

      final loginResponse = LoginResponseModel.fromJson(response);

      if (!_isValidLoginResponse(loginResponse)) {
        _setError(_authFailedError);
        return false;
      }

      await _handleSuccessfulLogin(loginResponse, context);
      return true;

    } catch (e) {
      if (!_isDisposed) {
        _handleLoginError(e);
      }
      return false;
    } finally {
      if (!_isDisposed) {
        _setLoadingState(false);
      }
    }
  }

  bool _validateInputs() {
    if (_isDisposed) return false;

    final username = emailController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _setError(_emptyFieldsError);
      return false;
    }

    _clearError();
    return true;
  }

  LoginRequestModel _createLoginRequest() {
    return LoginRequestModel(
      username: emailController.text.trim(),
      password: passwordController.text,
    );
  }

  bool _isValidLoginResponse(LoginResponseModel response) {
    return response.accessToken != null && response.accessToken!.isNotEmpty;
  }

  Future<void> _handleSuccessfulLogin(
      LoginResponseModel loginResponse,
      BuildContext context,
      ) async {
    if (_isDisposed || !context.mounted) return;

    try {
      if (loginResponse.login != null && loginResponse.login!.isNotEmpty) {
        await SharedPrefsService.instance.saveLoginType(loginResponse.login!);
      } else {
        debugPrint("Warning: Login type is null or empty in response");
      }

      await Future.wait([
        SharedPrefsService.instance.saveLoginResponse(loginResponse),
        SharedPrefsService.instance.saveUsername(emailController.text.trim()),
      ]);

      if (_isDisposed || !context.mounted) return;

      try {
        await _firebaseMessagingService.sendTokenToServerAfterLogin();
      } catch (e) {
        debugPrint("Firebase token error: $e");
      }

      if (!_isDisposed && context.mounted) {
        await _requestLocationPermission(context);
        if (!_isDisposed && context.mounted) {
          await _navigateBasedOnLoginType(context, loginResponse.login);
        }
      }
    } catch (e) {
      debugPrint("Error in successful login handler: $e");
      if (!_isDisposed) {
        _setError("Login successful but navigation failed. Please try again.");
      }
    }
  }

  void _handleLoginError(dynamic error) {
    if (_isDisposed) return;

    debugPrint("Login error: $error");

    if (error is HttpException) {
      _setError(error.statusCode == 401
          ? _invalidCredentialsError
          : "Server error: ${error.message}");
    } else {
      _setError("An error occurred. Please check your connection and try again.");
    }
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    if (_isDisposed || !context.mounted) return;

    try {
      await _locationService.handleLocationPermission(context);
    } catch (e) {
      debugPrint("Location permission error: $e");
    }
  }

  Future<void> _navigateBasedOnLoginType(BuildContext context, String? loginType) async {
    if (_isDisposed || !context.mounted) return;

    Widget destinationScreen;

    switch (loginType?.toLowerCase()) {
      case 'applicant':
        destinationScreen = const HomeScreen();
        break;
      case 'client':
        destinationScreen = const ClientHomeScreen();
        break;
      default:
        debugPrint("Unknown login type: $loginType, defaulting to HomeScreen");
        destinationScreen = const HomeScreen();
        break;
    }

    try {
      if (!_isDisposed && context.mounted) {
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Navigation error: $e");
      if (!_isDisposed && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      }
    }
  }

  void navigateToSignup(BuildContext context) {
    if (_isDisposed || !context.mounted) return;

    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );
    } catch (e) {
      debugPrint("Navigation to signup error: $e");
    }
  }

  void _setLoadingState(bool loading) {
    if (_isDisposed) return;

    if (isLoading.value != loading) {
      isLoading.value = loading;
    }
  }

  void _setError(String error) {
    if (_isDisposed) return;

    if (errorMessage.value != error) {
      errorMessage.value = error;
    }
  }

  void _clearError() {
    if (_isDisposed) return;

    if (errorMessage.value != null) {
      errorMessage.value = null;
    }
  }

  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;

    try {
      emailController.dispose();
      passwordController.dispose();
      obscureText.dispose();
      isLoading.dispose();
      errorMessage.dispose();
    } catch (e) {
      debugPrint("Error disposing LoginController: $e");
    }
  }
}

class HttpException implements Exception {
  final int statusCode;
  final String message;

  const HttpException(this.statusCode, this.message);

  @override
  String toString() => 'HttpException: $statusCode - $message';
}