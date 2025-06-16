import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ClientHomeController {
  final ApiService _apiService;
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  ClientHomeController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    initialize();
  }

  void initialize() {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }

    debugPrint("🔄 Initializing Client Home Controller...");
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  Future<void> refreshDashboardData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      debugPrint("🔄 Refreshing client dashboard data...");
      await Future.delayed(const Duration(seconds: 1));
      debugPrint("✅ Client dashboard data refreshed");
    } catch (e) {
      errorMessage.value = "Failed to refresh dashboard data: ${e.toString()}";
      debugPrint("❌ Error refreshing client dashboard data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToProfile(BuildContext context) {
    debugPrint("👤 Navigate to client profile screen");
  }

  void navigateToSettings(BuildContext context) {
    debugPrint("⚙️ Navigate to client settings screen");
  }

  Future<void> logout(BuildContext context) async {
    try {
      debugPrint("🔑 Attempting to logout client...");
      isLoading.value = true;
      errorMessage.value = null;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final token = SharedPrefsService.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        _apiService.client.addAuthToken(token);
      }

      await _apiService.getUserLogout();
      debugPrint("✅ Client logout API call successful");

      await SharedPrefsService.instance.clear();
      debugPrint("✅ Local preferences cleared");

      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        debugPrint("✅ Redirected to login screen");
      }
    } catch (e) {
      errorMessage.value = "Failed to logout: ${e.toString()}";
      debugPrint("❌ Error during client logout: $e");

      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.value ?? "Unknown error occurred"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    debugPrint("🧹 Disposing ClientHomeController resources");
    selectedIndex.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}