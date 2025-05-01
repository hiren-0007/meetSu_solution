import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meetsu_solutions/utils/extra/file_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadHelper {
  static Future<String?> downloadFile({
    required BuildContext context,
    required String url,
    required String fileName,
    String? title,
    Map<String, String>? headers,
  }) async {
    try {
      // Get the appropriate directory for storing files
      Directory? directory;

      if (Platform.isAndroid) {
        // For Android, use app's external files directory which doesn't require
        // special permissions on Android 10+
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception("Could not access storage directory");
      }

      debugPrint("📁 Saving to directory: ${directory.path}");

      // Create downloads subdirectory if it doesn't exist
      final downloadsDir = Directory('${directory.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Create file path
      final String filePath = '${downloadsDir.path}/$fileName';
      final File file = File(filePath);

      // Check if file already exists and delete it
      if (await file.exists()) {
        await file.delete();
      }

      // Download the file
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Write file to storage
        await file.writeAsBytes(response.bodyBytes);
        debugPrint("✅ File downloaded successfully to: $filePath");

        return filePath;
      } else {
        throw Exception("Failed to download file: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Download error: $e");
      return null;
    }
  }

  // Alternative method using FileProvider for sharing with other apps
  static Future<String?> downloadAndShareFile({
    required BuildContext context,
    required String url,
    required String fileName,
    String? title,
    Map<String, String>? headers,
  }) async {
    final filePath = await downloadFile(
      context: context,
      url: url,
      fileName: fileName,
      title: title,
      headers: headers,
    );

    if (filePath != null && context.mounted) {
      // Use your existing FileUtils to share
      await FileUtils.shareFile(filePath, context: context);
    }

    return filePath;
  }
}