import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ClientDashboardController {
  final ApiService _apiService;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> hasData = ValueNotifier<bool>(false);


  ClientDashboardController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    initialize();
  }

  void initialize() {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }

    debugPrint("🔄 Initializing Client Dashboard Controller...");
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      debugPrint("🔄 Fetching client dashboard data...");

      // Simulating API call delay
      await Future.delayed(const Duration(seconds: 2));

      hasData.value = false;


      debugPrint("✅ Client dashboard data fetched. Has data: ${hasData.value}");
    } catch (e) {
      errorMessage.value = "Failed to load dashboard data: ${e.toString()}";
      hasData.value = false;
      debugPrint("❌ Error fetching client dashboard data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    debugPrint("🧹 Disposing ClientDashboardController resources");
    isLoading.dispose();
    errorMessage.dispose();
    hasData.dispose();
    // Dispose any other ValueNotifiers you add
  }
}