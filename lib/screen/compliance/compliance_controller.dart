import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/more/training/training_controller.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class ComplianceController {
  final ApiService _apiService;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<List<ComplianceReport>> reports =
  ValueNotifier<List<ComplianceReport>>([]);

  ComplianceController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    fetchComplianceReports();
  }

  Future<void> fetchComplianceReports() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final token = SharedPrefsService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No authentication token found");
      }

      _apiService.client.addAuthToken(token);

      final response = await _apiService.getCompliance();

      if (response['data'] != null) {
        final List<dynamic> reportsData = response['data'];

        final List<ComplianceReport> complianceReports =
        reportsData.map((report) {
          return ComplianceReport(
            name: report['name'] ?? "Unnamed Report",
            id: report['id'] ?? 0,
          );
        }).toList();

        reports.value = complianceReports;
      } else {
        throw Exception("Invalid response format or no data available");
      }
    } catch (e) {
      debugPrint("❌ Error fetching compliance reports: $e");
      errorMessage.value =
      "Failed to load compliance reports. Please try again later.";
      reports.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showPdf(ComplianceReport report, BuildContext context) async {

    final token = SharedPrefsService.instance.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("No authentication token found");
    }

    _apiService.client.addAuthToken(token);

    final userData = {
      "id": report.id.toString(),
    };
    final response = await _apiService.complianceDownload(userData);
    final String filePath = response['filename'];
    if (filePath.isNotEmpty) {

      String fullUrl = filePath;
      if (filePath.startsWith('/http')) {
        fullUrl = filePath.substring(1);
      }

      fullUrl = fullUrl.replaceAll(' ', '%20');
      debugPrint("🔗 Fixed URL: $fullUrl");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(pdfUrl: fullUrl),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PDF file path not found"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void retryFetch() {
    fetchComplianceReports();
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    reports.dispose();
  }
}

class ComplianceReport {
  final String name;
  final int id;

  ComplianceReport({
    required this.name,
    required this.id,
  });
}