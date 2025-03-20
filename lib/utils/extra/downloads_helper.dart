import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class FileDownloadHelper {
  /// Download a file from a URL and save it to the device
  static Future<String?> downloadFile({
    required BuildContext context,
    required String url,
    required String fileName,
    required String token,
    String? displayName,
  }) async {
    try {
      // 1. Request permissions first
      bool hasPermission = await _requestPermissions(context);
      if (!hasPermission) {
        throw Exception("Storage permission denied");
      }

      // 2. Show download progress dialog
      if (context.mounted) {
        _showDownloadProgressDialog(context, displayName ?? fileName);
      }

      // 3. Get directory to save file
      final directory = await _getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';
      debugPrint("📁 Saving file to: $filePath");

      // 4. Ensure the directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 5. Configure Dio for download
      final dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $token";

      // 6. Download the file
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

      // 7. Close progress dialog
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // 8. Verify file exists
      final file = File(filePath);
      if (await file.exists()) {
        debugPrint("✅ File downloaded successfully: $filePath (${await file.length()} bytes)");

        // 9. Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded: ${displayName ?? fileName}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        return filePath;
      } else {
        throw Exception("File was not saved correctly");
      }
    } catch (e) {
      // Handle errors
      debugPrint("❌ Error downloading file: $e");

      // Close dialog if it's open
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return null;
    }
  }

  /// Request appropriate permissions based on Android version
  static Future<bool> _requestPermissions(BuildContext context) async {
    if (Platform.isIOS) {
      // iOS doesn't need explicit permissions for app documents
      return true;
    }

    if (!Platform.isAndroid) {
      // For other platforms
      return true;
    }

    try {
      // Direct approach - try storage permission first
      debugPrint("📱 Requesting storage permission directly");
      var status = await Permission.storage.request();

      if (status.isGranted) {
        debugPrint("✅ Storage permission granted");
        return true;
      }

      debugPrint("❌ Storage permission denied, showing explanation dialog");

      // If denied, show explanation dialog
      if (context.mounted) {
        bool shouldOpenSettings = await showDialog<bool>(
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

        if (shouldOpenSettings && context.mounted) {
          await openAppSettings();
        }
      }

      return false;
    } catch (e) {
      debugPrint("Error requesting permissions: $e");
      return false;
    }
  }

  /// Show download progress dialog
  static void _showDownloadProgressDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Downloading..."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Downloading $name"),
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

  /// Get Android SDK version
  static Future<int> _getAndroidSdkVersion() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = Platform.operatingSystemVersion;

        // Try to extract SDK version
        final RegExp regExp = RegExp(r'API-(\d+)');
        final match = regExp.firstMatch(androidInfo);

        if (match != null && match.groupCount >= 1) {
          return int.parse(match.group(1)!);
        }

        // Fallback to checking for version names
        if (androidInfo.contains('13')) return 33;
        if (androidInfo.contains('12')) return 31;
        if (androidInfo.contains('11')) return 30;
        if (androidInfo.contains('10')) return 29;

        // Default assumption for older versions
        return 28;
      }

      return 0; // Not Android
    } catch (e) {
      debugPrint("Error determining Android version: $e");
      return 29; // Default to Android 10
    }
  }

  /// Get the appropriate directory for downloads
  static Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      try {
        // For Android 10 (API 29), try app's external files directory first
        // This approach doesn't require special permissions on Android 10+
        final dirs = await getExternalStorageDirectories();
        if (dirs != null && dirs.isNotEmpty) {
          final dir = Directory('${dirs[0].path}/Download');
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          debugPrint("📁 Using app's external files directory: ${dir.path}");
          return dir;
        }
      } catch (e) {
        debugPrint("Error accessing external app directory: $e");
      }

      try {
        // Fallback to app's documents directory - this should always work
        // and doesn't require special permissions
        final appDir = await getApplicationDocumentsDirectory();
        final downloadDir = Directory('${appDir.path}/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        debugPrint("📁 Using app documents directory: ${downloadDir.path}");
        return downloadDir;
      } catch (e) {
        debugPrint("Error accessing app directory: $e");

        // Last resort - temporary directory
        final tempDir = await getTemporaryDirectory();
        final downloadDir = Directory('${tempDir.path}/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir;
      }
    } else {
      // For iOS and other platforms
      return await getApplicationDocumentsDirectory();
    }
  }
}