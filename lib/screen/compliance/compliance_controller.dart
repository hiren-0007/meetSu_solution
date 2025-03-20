import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/extra/downloads_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'dart:io';

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

  // Updated method for ComplianceController class
  // Add this to your ComplianceController class
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

        // Show download progress dialog
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Downloading..."),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Downloading ${report.name}"),
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(),
                  ],
                ),
              );
            },
          );
        }

        // Get app documents directory (doesn't require special permissions)
        final appDir = await getApplicationDocumentsDirectory();
        final downloadDir = Directory('${appDir.path}/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        final localFilePath = '${downloadDir.path}/$fileName';
        debugPrint("📁 Saving file to: $localFilePath");

        // Download using Dio
        final dio = Dio();
        dio.options.headers["Authorization"] = "Bearer $token";

        await dio.download(
          fullUrl,
          localFilePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = (received / total * 100).toStringAsFixed(0);
              debugPrint('Download progress: $progress%');
            }
          },
        );

        // Close dialog if it's open
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Verify file exists and show success
        final file = File(localFilePath);
        if (await file.exists()) {

          debugPrint("✅ File downloaded successfully: $localFilePath (${await file.length()} bytes)");

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloaded: ${report.name}\nSaved to app folder'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return true;
        } else {
          throw Exception("File was not saved correctly");
        }
      } else {
        throw Exception("Invalid response or download failed");
      }
    } catch (e) {
      debugPrint("❌ Error downloading report: $e");
      errorMessage.value = "Failed to download report: ${e.toString()}";

      // Close dialog if it's open
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

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

  // Improved download method with better permission handling
  Future<void> _downloadFile(
      BuildContext context,
      String url,
      String token,
      String fileName,
      String reportName
      ) async {
    try {
      // Request the right permissions for the device's Android version
      bool hasPermission = await _requestStoragePermission(context);

      if (!hasPermission) {
        debugPrint("❌ Permission denied");
        return;
      }

      // Show download progress dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Downloading..."),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Downloading $reportName"),
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      }

      // Get directory to save file
      final directory = await _getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';
      debugPrint("📁 Saving file to: $filePath");

      // Ensure the directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Configure Dio for download
      final dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";

      // Download the file
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('Download progress: $progress%');
          }
        },
      );

      // Close progress dialog
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Verify file exists
      final file = File(filePath);
      if (await file.exists()) {
        debugPrint("✅ File downloaded successfully: $filePath (${await file.length()} bytes)");

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded: $reportName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception("File was not saved correctly");
      }
    } catch (e) {
      // Close progress dialog if it's open
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      debugPrint("❌ Error in _downloadFile: $e");
      rethrow; // Re-throw to be caught by calling method
    }
  }

// Updated method from ComplianceController class
  Future<bool> _requestStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) {
      // For iOS and other platforms, we don't need explicit storage permission
      return true;
    }

    // Get Android version
    int androidVersion = await _getAndroidVersion();
    debugPrint("📱 Android version: $androidVersion");

    // Different permission strategy based on Android version
    if (androidVersion >= 33) {
      // Android 13+: Need media permissions
      final photos = await Permission.photos.request();
      if (photos.isGranted) {
        return true;
      }
    } else if (androidVersion >= 30) {
      // Android 11 & 12: Need manage external storage
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      }
    } else {
      // Android 10 and below: Need storage permission
      if (await Permission.storage.isGranted) {
        return true;
      }

      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
    }

    // If we get here, permission was denied
    if (context.mounted) {
      // Show explanation dialog
      bool shouldRetry = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Storage Permission Required"),
          content: const Text(
              "This app needs storage permission to download and save files. "
                  "Without this permission, downloads cannot be saved to your device."
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Open Settings"),
            ),
          ],
        ),
      ) ?? false;

      if (shouldRetry && context.mounted) {
        await openAppSettings();
      }
    }

    return false;
  }

  // Get Android version number
  Future<int> _getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        final String androidVersion = Platform.operatingSystemVersion.toLowerCase();

        // Try to extract the version number using regex
        final RegExp regExp = RegExp(r'android\s+(\d+)');
        final match = regExp.firstMatch(androidVersion);

        if (match != null && match.groupCount >= 1) {
          return int.parse(match.group(1)!);
        }

        // Manual detection
        if (androidVersion.contains('13')) {
          return 33; // Android 13
        } else if (androidVersion.contains('12')) {
          return 31; // Android 12
        } else if (androidVersion.contains('11')) {
          return 30; // Android 11
        } else if (androidVersion.contains('10')) {
          return 29; // Android 10
        } else {
          return 28; // Default to Android 9
        }
      }
      return 0; // Not Android
    } catch (e) {
      debugPrint("❌ Error determining Android version: $e");
      return 28; // Default to Android 9
    }
  }

  // Get the appropriate directory for downloads based on platform
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Try to get the downloads directory directly
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          return downloadsDir;
        }
      } catch (e) {
        debugPrint("❌ Error accessing Download folder: $e");
      }

      try {
        // Try to get the external storage directory
        final externalStorageDir = await getExternalStorageDirectory();
        if (externalStorageDir != null) {
          // Create a downloads subdirectory
          final downloadsDir = Directory('${externalStorageDir.path}/Download');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          return downloadsDir;
        }
      } catch (e) {
        debugPrint("❌ Error accessing external storage: $e");
      }

      // Fallback to application directory
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    } else {
      // For iOS and other platforms
      final appDir = await getApplicationDocumentsDirectory();
      return appDir;
    }
  }

  // Show permission dialog
  void _showPermissionDialog(BuildContext context, bool isPermanentlyDenied) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Storage Permission Required"),
        content: Text(
            isPermanentlyDenied
                ? "This app needs storage permission to download and save files. Please enable it in app settings."
                : "This app needs storage permission to download and save files. Please grant this permission to download files."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (isPermanentlyDenied) {
                await openAppSettings();
              } else {
                // Try to request permission again
                await _requestStoragePermission(context);
              }
            },
            child: Text(isPermanentlyDenied ? "Open Settings" : "Try Again"),
          ),
        ],
      ),
    );
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