import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class StoragePermissionHelper {
  /// Request storage permissions and handle different scenarios
  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      // Check Android version
      if (await _isAndroid13OrAbove()) {
        // For Android 13+, we need to use new storage permissions
        return await _requestAndroid13Permissions(context);
      } else {
        // For lower Android versions, use the storage permission
        return await _requestLegacyStoragePermission(context);
      }
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit storage permission for app's documents directory
      return true;
    }
    return false;
  }

  /// Check if device is running Android 13 or above
  static Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      return sdkInt >= 33; // Android 13 is API level 33
    }
    return false;
  }

  /// Get Android SDK version
  static Future<int> _getAndroidSdkVersion() async {
    try {
      // This is a simple way to get the SDK version, but in a real app,
      // you might want to use a plugin that gives you this information
      final String androidVersion = Platform.operatingSystemVersion;
      final RegExp regex = RegExp(r'API-(\d+)');
      final match = regex.firstMatch(androidVersion);
      if (match != null && match.groupCount >= 1) {
        return int.parse(match.group(1)!);
      }

      // Fallback: Check for predictable version numbers in the string
      if (androidVersion.contains('13')) {
        return 33;
      } else if (androidVersion.contains('12')) {
        return 31;
      } else if (androidVersion.contains('11')) {
        return 30;
      } else if (androidVersion.contains('10')) {
        return 29;
      }

      // Default to a safe assumption
      return 29; // Assume Android 10 as baseline
    } catch (e) {
      debugPrint('Error getting Android SDK version: $e');
      return 29; // Assume Android 10 as baseline
    }
  }

  /// Request legacy storage permission (pre-Android 13)
  static Future<bool> _requestLegacyStoragePermission(BuildContext context) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      return await _showPermissionSettingsDialog(
          context,
          'Storage Permission Required',
          'This app needs storage permission to download and save files. Please enable it in app settings.'
      );
    } else {
      // Permission denied but not permanently
      return await _showPermissionExplanationDialog(
          context,
          'Storage Permission Needed',
          'We need storage permission to download and save files to your device. Please grant this permission.'
      );
    }
  }

  /// Request Android 13+ permissions (more granular approach)
  static Future<bool> _requestAndroid13Permissions(BuildContext context) async {
    // For downloading files, photos permission is usually sufficient
    final status = await Permission.photos.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      return await _showPermissionSettingsDialog(
          context,
          'Photos Permission Required',
          'This app needs permission to save files to your device. Please enable it in app settings.'
      );
    } else {
      // Permission denied but not permanently
      return await _showPermissionExplanationDialog(
          context,
          'Permission Needed',
          'We need permission to save files to your device. Please grant this permission.'
      );
    }
  }

  /// Show dialog explaining why we need the permission with retry option
  static Future<bool> _showPermissionExplanationDialog(
      BuildContext context,
      String title,
      String message,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('RETRY'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show dialog to open app settings when permission is permanently denied
  static Future<bool> _showPermissionSettingsDialog(
      BuildContext context,
      String title,
      String message,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await openAppSettings();
            },
            child: const Text('OPEN SETTINGS'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}