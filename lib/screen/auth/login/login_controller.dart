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

import '../../../services/firebase/firebase_messaging_service.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> obscureText = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  final ApiService _apiService = ApiService(ApiClient());

  final LocationService _locationService = LocationService();

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  Future<bool> login(BuildContext context) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final username = emailController.text.trim();
      final password = passwordController.text;

      if (username.isEmpty || password.isEmpty) {
        errorMessage.value = "Please enter both username and password";
        return false;
      }

      final loginRequest = LoginRequestModel(
        username: username,
        password: password,
      );

      final response = await _apiService.loginUser(loginRequest.toJson());

      final loginResponse = LoginResponseModel.fromJson(response);

      if (loginResponse.accessToken != null &&
          loginResponse.accessToken!.isNotEmpty) {
        await SharedPrefsService.instance.saveLoginResponse(loginResponse);

        await SharedPrefsService.instance.saveUsername(username);

        final firebaseMessagingService = FirebaseMessagingService();
        await firebaseMessagingService.sendTokenToServerAfterLogin();


        if (loginResponse.isTempLogin == 1) {
          debugPrint("Temporary login detected, user should change password");
        }

        if (context.mounted) {
          await requestLocationPermission(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
              // MaterialPageRoute(builder: (context) => const ClientHomeScreen()));
        }
        return true;
      } else {
        errorMessage.value =
            "Authentication failed. Please check your credentials.";
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

  Future<void> requestLocationPermission(BuildContext context) async {
    await _locationService.handleLocationPermission(context);
  }

  void navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    obscureText.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
