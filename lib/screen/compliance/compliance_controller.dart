import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/extra/file_utils.dart';

import '../../utils/extra/downloads_helper.dart';

class ComplianceController {
  // API Service
  final ApiService _apiService;

  // ValueNotifiers for reactive state management
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
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

  // Improved download method with simplified implementation
  Future<bool> simpleDownloadReport(BuildContext context, ComplianceReport report) async {
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

      // Prepare data for the API call
      final userData = {
        "id": report.id.toString(),
      };

      // Make the API call to download the report
      final downloadResponse = await _apiService.complianceDownload(userData);
      debugPrint("📥 Download response: $downloadResponse");

      // Extract the filename from the response
      if (downloadResponse != null &&
          downloadResponse['filename'] != null &&
          downloadResponse['statusCode'] == 200) {

        final String filePath = downloadResponse['filename'];
        String baseUrl = 'https://www.meetsusolutions.com';
        String normalizedPath = filePath.startsWith('/') ? filePath : '/$filePath';
        String fullUrl = '$baseUrl$normalizedPath'.replaceAll(' ', '%20');
        String fileName = fullUrl.split('/').last;
        debugPrint("🔗 Download URL: $fullUrl");

        // Use our simplified DownloadHelper to download the file
        final downloadedFilePath = await DownloadHelper.downloadFile(
          context: context,
          url: fullUrl,
          fileName: fileName,
          title: report.name,
          headers: {"Authorization": "Bearer $token"},
        );

        // Check if download was successful
        if (downloadedFilePath != null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloaded: ${report.name}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'VIEW',
                  onPressed: () {
                    // Open the file using FileUtils
                    FileUtils.openFile(downloadedFilePath, context: context);
                  },
                ),
              ),
            );
          }
          return true;
        } else {
          throw Exception("Download failed");
        }
      } else {
        throw Exception("Invalid response or download failed");
      }
    } catch (e) {
      debugPrint("❌ Error downloading report: $e");
      errorMessage.value = "Failed to download report: ${e.toString()}";

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    } finally {
      isLoading.value = false;
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