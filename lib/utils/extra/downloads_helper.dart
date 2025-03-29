import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadHelper {
  // Request storage permissions based on Android version
  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) {
      // For iOS and other platforms, we don't need explicit storage permission
      return true;
    }

    // Try all relevant permissions for various Android versions
    bool hasPermission = false;

    // For Android 13+
    if (await Permission.photos.isGranted) {
      hasPermission = true;
    } else {
      final photosStatus = await Permission.photos.request();
      hasPermission = photosStatus.isGranted;
    }

    // For Android 11 & 12
    if (!hasPermission) {
      if (await Permission.manageExternalStorage.isGranted) {
        hasPermission = true;
      } else {
        final storageStatus = await Permission.manageExternalStorage.request();
        hasPermission = storageStatus.isGranted;
      }
    }

    // For Android 10 and below
    if (!hasPermission) {
      if (await Permission.storage.isGranted) {
        hasPermission = true;
      } else {
        final storageStatus = await Permission.storage.request();
        hasPermission = storageStatus.isGranted;
      }
    }

    // If permission is still denied, show the explanation dialog
    if (!hasPermission && context.mounted) {
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
        // Check if permission was granted in settings
        if (await Permission.storage.isGranted ||
            await Permission.manageExternalStorage.isGranted ||
            await Permission.photos.isGranted) {
          hasPermission = true;
        }
      }
    }

    return hasPermission;
  }

  // Get the appropriate directory for downloads based on platform
  static Future<Directory> getDownloadDirectory() async {
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

  // Download file with progress dialog and snackbar feedback
  static Future<String?> downloadFile({
    required BuildContext context,
    required String url,
    required String fileName,
    required String title,
    Map<String, String>? headers,
  }) async {
    // For tracking progress
    ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);

    try {
      // Request permissions
      bool hasPermission = await requestStoragePermission(context);
      if (!hasPermission) {
        debugPrint("❌ Permission denied");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission denied. Cannot download file.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      // Get directory to save file
      final directory = await getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';
      debugPrint("📁 Saving file to: $filePath");

      // Ensure the directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Show download progress dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Downloading $title"),
              content: ValueListenableBuilder<double>(
                valueListenable: progressNotifier,
                builder: (context, progress, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 10),
                      Text("${(progress * 100).toStringAsFixed(0)}%"),
                    ],
                  );
                },
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

      // Configure Dio for download
      final dio = Dio();
      if (headers != null) {
        dio.options.headers.addAll(headers);
      }

      // Download the file
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Calculate progress percentage
            final newProgress = received / total;
            // Update the progress
            progressNotifier.value = newProgress;
          }
        },
      );

      // Close dialog if it's open
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Cleanup
      progressNotifier.dispose();

      // Verify file exists
      final file = File(filePath);
      if (await file.exists()) {
        debugPrint("✅ File downloaded successfully: $filePath (${await file.length()} bytes)");

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded: $title'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'VIEW',
                onPressed: () {
                  // Implement file opening functionality
                  // You can use FileUtils.openFile(filePath, context: context) here
                },
              ),
            ),
          );
        }

        return filePath;
      } else {
        throw Exception("File was not saved correctly");
      }
    } catch (e) {
      debugPrint("❌ Error in downloadFile: $e");

      // Close dialog if it's open
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      return null;
    }
  }
}