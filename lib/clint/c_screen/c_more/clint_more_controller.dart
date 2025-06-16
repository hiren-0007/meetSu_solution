import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ClintMoreController {
  final ApiService _apiService;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);

  ClintMoreController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    initialize();
  }

  void initialize() {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }

    debugPrint("🔄 Initializing Client More Controller...");
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      debugPrint("🔄 Fetching client more screen data...");

      // Simulating API call delay - replace with your actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Set data availability flag
      hasData.value = true;

      debugPrint("✅ Client more screen data fetched successfully");
    } catch (e) {
      errorMessage.value = "Failed to load data: ${e.toString()}";
      hasData.value = false;
      debugPrint("❌ Error fetching client more screen data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void navigateTo(BuildContext context, String route) {
    debugPrint("🔄 Navigating to: $route");
    Navigator.of(context).pushNamed(route);
  }

  void handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text("Logout"),
            ],
          ),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Logout"),
              onPressed: () => _performLogout(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      isLoading.value = true;
      debugPrint("🔄 Performing logout...");

      await _apiService.getClintLogout();

      await SharedPrefsService.instance.clear();

      debugPrint("✅ Logout successful");

      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      debugPrint("❌ Error during logout: $e");

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    debugPrint("🧹 Disposing ClintMoreController resources");
    isLoading.dispose();
    errorMessage.dispose();
    hasData.dispose();
  }
}