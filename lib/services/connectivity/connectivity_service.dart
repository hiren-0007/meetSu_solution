import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ConnectivityService {
  // Singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  // Connectivity instance
  final Connectivity _connectivity = Connectivity();

  // Stream controller for connectivity status
  final StreamController<ConnectivityResult> _connectionStatusController =
  StreamController<ConnectivityResult>.broadcast();

  // Getter for the stream
  Stream<ConnectivityResult> get connectionStatusStream =>
      _connectionStatusController.stream;

  // Initialize the service
  void initialize() {
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Use the first result from the list, which is typically the primary connection
      if (results.isNotEmpty) {
        _connectionStatusController.add(results.first);
      } else {
        _connectionStatusController.add(ConnectivityResult.none);
      }
    });

    // Check initial connectivity
    checkConnectivity();
  }

  // Check current connectivity
  Future<ConnectivityResult> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    // Use the first result from the list, which is typically the primary connection
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _connectionStatusController.add(result);
    return result;
  }

  // Check if connected to the internet
  Future<bool> isConnected() async {
    final result = await checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Request internet permission (for Android)
  Future<bool> requestInternetPermission() async {
    // Internet permission is automatically added in the manifest
    // but for some devices, you might want to check and request explicitly
    var status = await Permission.nearbyWifiDevices.status;

    if (status.isDenied) {
      status = await Permission.nearbyWifiDevices.request();
    }

    return status.isGranted;
  }

  // Show no internet dialog
  void showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
            'Please check your internet connection and try again.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
            TextButton(
              child: const Text('Retry'),
              onPressed: () async {
                Navigator.of(context).pop();
                final isConnected = await this.isConnected();
                if (!isConnected && context.mounted) {
                  showNoInternetDialog(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Show internet connectivity snackbar
  void showConnectivitySnackBar(BuildContext context, ConnectivityResult result) {
    // final snackBar = SnackBar(
    //   content: Text(
    //     result == ConnectivityResult.none
    //         ? 'You are offline'
    //         : 'You are online on ${result.name}',
    //   ),
    //   backgroundColor: result == ConnectivityResult.none
    //       ? Colors.red
    //       : Colors.green,
    //   duration: const Duration(seconds: 2),
    // );

    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Dispose resources
  void dispose() {
    _connectionStatusController.close();
  }
}