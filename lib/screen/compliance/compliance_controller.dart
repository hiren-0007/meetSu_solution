import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ComplianceController {
  final ApiService _apiService;

  // State management with ValueNotifiers
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<List<ComplianceReport>> reports = ValueNotifier<List<ComplianceReport>>([]);

  // Cache management
  bool _isInitialized = false;
  String? _cachedToken;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  ComplianceController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    _initializeAndFetch();
  }

  /// Initialize controller and fetch reports
  Future<void> _initializeAndFetch() async {
    await _initializeWithToken();
    await fetchComplianceReports();
  }

  /// Initialize API client with authentication token
  Future<bool> _initializeWithToken() async {
    if (_isInitialized && _cachedToken != null) {
      return true;
    }

    try {
      final token = SharedPrefsService.instance.getAccessToken();
      if (token?.isNotEmpty == true) {
        _apiService.client.addAuthToken(token!);
        _cachedToken = token;
        _isInitialized = true;
        debugPrint('✅ Compliance token initialized successfully');
        return true;
      } else {
        throw Exception("No authentication token found");
      }
    } catch (e) {
      debugPrint('❌ Token initialization failed: $e');
      return false;
    }
  }

  /// Check if cached data is still valid
  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    final now = DateTime.now();
    return now.difference(_lastFetchTime!).compareTo(_cacheValidDuration) < 0;
  }

  /// Fetch compliance reports from API
  Future<void> fetchComplianceReports({bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid() && reports.value.isNotEmpty) {
      debugPrint('📋 Using cached compliance reports');
      return;
    }

    if (isLoading.value) {
      debugPrint('⏳ Fetch already in progress');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final hasToken = await _initializeWithToken();
      if (!hasToken) {
        throw Exception("Authentication required. Please login again.");
      }

      debugPrint('📋 Fetching compliance reports...');
      final response = await _apiService.getCompliance();

      if (response['data'] != null) {
        final List<dynamic> reportsData = response['data'];

        if (reportsData.isEmpty) {
          reports.value = [];
          _lastFetchTime = DateTime.now();
          debugPrint('📋 No compliance reports available');
          return;
        }

        final List<ComplianceReport> complianceReports = reportsData
            .map((report) => _parseComplianceReport(report))
            .where((report) => report != null)
            .cast<ComplianceReport>()
            .toList();

        reports.value = complianceReports;
        _lastFetchTime = DateTime.now();

        debugPrint('✅ Successfully loaded ${complianceReports.length} compliance reports');
      } else {
        throw Exception("Invalid response format: missing data field");
      }
    } catch (e) {
      debugPrint('❌ Error fetching compliance reports: $e');
      _handleFetchError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Parse compliance report from API response
  ComplianceReport? _parseComplianceReport(dynamic reportData) {
    try {
      if (reportData is! Map<String, dynamic>) {
        debugPrint('⚠️ Invalid report data format');
        return null;
      }

      final name = reportData['name']?.toString();
      final id = reportData['id'];

      if (name?.isEmpty ?? true) {
        debugPrint('⚠️ Report missing name field');
        return null;
      }

      // Handle different ID types
      int parsedId;
      if (id is int) {
        parsedId = id;
      } else if (id is String) {
        parsedId = int.tryParse(id) ?? 0;
      } else {
        debugPrint('⚠️ Report missing valid ID field');
        return null;
      }

      return ComplianceReport(
        name: name!,
        id: parsedId,
      );
    } catch (e) {
      debugPrint('❌ Error parsing report data: $e');
      return null;
    }
  }

  /// Handle fetch errors with appropriate user messages
  void _handleFetchError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('token') || errorString.contains('Authentication')) {
      errorMessage.value = "Session expired. Please login again.";
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      errorMessage.value = "Network error. Please check your connection and try again.";
    } else if (errorString.contains('timeout')) {
      errorMessage.value = "Request timed out. Please try again.";
    } else if (errorString.contains('404')) {
      errorMessage.value = "Compliance service not available.";
    } else if (errorString.contains('500')) {
      errorMessage.value = "Server error. Please try again later.";
    } else {
      errorMessage.value = "Failed to load compliance reports. Please try again.";
    }

    // Clear reports on error
    reports.value = [];
  }

  /// Show PDF document
  Future<void> showPdf(ComplianceReport report, BuildContext context) async {
    if (isLoading.value) {
      debugPrint('⏳ Another operation in progress');
      return;
    }

    try {
      _setLoading(true);
      HapticFeedback.mediumImpact();

      final hasToken = await _initializeWithToken();
      if (!hasToken) {
        throw Exception("Authentication required");
      }

      debugPrint('📄 Fetching PDF for report: ${report.name}');

      final userData = {"id": report.id.toString()};
      final response = await _apiService.complianceDownload(userData);

      final String? filePath = response['filename']?.toString();

      if (filePath?.isNotEmpty != true) {
        throw Exception("PDF file path not found in response");
      }

      String fullUrl = _sanitizeUrl(filePath!);
      debugPrint('🔗 Opening PDF URL: $fullUrl');

      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              pdfUrl: fullUrl,
              title: report.name,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error showing PDF: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, _getPdfErrorMessage(e));
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Sanitize and fix URL format
  String _sanitizeUrl(String url) {
    String cleanUrl = url.trim();

    // Remove leading slash if followed by http
    if (cleanUrl.startsWith('/http')) {
      cleanUrl = cleanUrl.substring(1);
    }

    // URL encode spaces and special characters
    cleanUrl = cleanUrl.replaceAll(' ', '%20');
    cleanUrl = cleanUrl.replaceAll('\n', '');
    cleanUrl = cleanUrl.replaceAll('\r', '');

    return cleanUrl;
  }

  /// Get appropriate error message for PDF operations
  String _getPdfErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('file path')) {
      return "PDF file not available";
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return "Network error. Cannot load PDF";
    } else if (errorString.contains('Authentication')) {
      return "Authentication required to view PDF";
    } else {
      return "Failed to open PDF. Please try again";
    }
  }

  /// Retry fetching reports
  Future<void> retryFetch() async {
    debugPrint('🔄 Retrying compliance reports fetch...');
    HapticFeedback.lightImpact();
    await fetchComplianceReports(forceRefresh: true);
  }

  /// Refresh reports (force refresh)
  Future<void> refreshReports() async {
    debugPrint('🔄 Refreshing compliance reports...');
    await fetchComplianceReports(forceRefresh: true);
  }

  /// Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Utility methods
  void _setLoading(bool loading) => isLoading.value = loading;
  void _clearError() => errorMessage.value = null;

  /// Reset controller state
  void reset() {
    _isInitialized = false;
    _cachedToken = null;
    _lastFetchTime = null;
    isLoading.value = false;
    errorMessage.value = null;
    reports.value = [];
  }

  /// Get cache status information
  Map<String, dynamic> getCacheInfo() {
    return {
      'isInitialized': _isInitialized,
      'hasToken': _cachedToken != null,
      'lastFetchTime': _lastFetchTime?.toString(),
      'isCacheValid': _isCacheValid(),
      'reportsCount': reports.value.length,
    };
  }

  /// Dispose all resources
  void dispose() {
    debugPrint('🗑️ Disposing ComplianceController');
    isLoading.dispose();
    errorMessage.dispose();
    reports.dispose();
  }
}

class ComplianceReport {
  final String name;
  final int id;

  const ComplianceReport({
    required this.name,
    required this.id,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComplianceReport &&
        other.name == name &&
        other.id == id;
  }

  @override
  int get hashCode => name.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'ComplianceReport(name: $name, id: $id)';
  }

  /// Create a copy of ComplianceReport with optional parameter overrides
  ComplianceReport copyWith({
    String? name,
    int? id,
  }) {
    return ComplianceReport(
      name: name ?? this.name,
      id: id ?? this.id,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }

  /// Create from JSON map
  factory ComplianceReport.fromJson(Map<String, dynamic> json) {
    return ComplianceReport(
      name: json['name']?.toString() ?? 'Unnamed Report',
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    );
  }
}


class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    this.title = "Training Document",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh the PDF
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewerScreen(
                    pdfUrl: pdfUrl,
                    title: title,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          debugPrint('📄 PDF loaded successfully: ${details.document.pages.count} pages');
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          debugPrint('❌ PDF load failed: ${details.error}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Failed to load document: ${details.error}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerScreen(
                      pdfUrl: pdfUrl,
                      title: title,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}