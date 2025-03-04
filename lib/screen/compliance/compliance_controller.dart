import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ComplianceController {
  // API Service
  final ApiService _apiService;

  // ValueNotifiers for reactive state management
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<List<ComplianceReport>> reports = ValueNotifier<List<ComplianceReport>>([]);

  // Constructor
  ComplianceController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    // Fetch compliance reports when controller is initialized
    fetchComplianceReports();
  }

  // Fetch compliance reports from the API
  Future<void> fetchComplianceReports() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Get user token from Shared Preferences
      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      // Add Authorization Token to API Client
      _apiService.client.addAuthToken(token);

      // Make API Call
      final response = await _apiService.getCompliance();

      // Check if response has data
      if (response != null && response['data'] != null) {
        final List<dynamic> reportsData = response['data'];

        // Convert API data to ComplianceReport objects
        final List<ComplianceReport> complianceReports = reportsData.map((report) {
          return ComplianceReport(
            name: report['name'] ?? "Unnamed Report",
            id: report['id'] ?? 0,
          );
        }).toList();

        // Update the reports list
        reports.value = complianceReports;
      } else {
        throw Exception("Invalid response format or no data available");
      }
    } catch (e) {
      debugPrint("❌ Error fetching compliance reports: $e");
      errorMessage.value = "Failed to load compliance reports. Please try again later.";
      reports.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Method to download a report
  Future<bool> downloadReport(BuildContext context, ComplianceReport report) async {
    errorMessage.value = null;
    isLoading.value = true;

    try {
      // Here you would implement actual download logic
      // For example:
      // final result = await _apiService.downloadReport(report.id);

      // Simulate download delay for now
      await Future.delayed(const Duration(seconds: 1));

      isLoading.value = false;

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded: ${report.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = "Failed to download report: ${e.toString()}";
      return false;
    }
  }

  // Retry fetching data
  void retryFetch() {
    fetchComplianceReports();
  }

  // Clean up resources
  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    reports.dispose();
  }
}

// Model class for compliance reports
class ComplianceReport {
  final String name;
  final int id;

  ComplianceReport({
    required this.name,
    required this.id,
  });
}