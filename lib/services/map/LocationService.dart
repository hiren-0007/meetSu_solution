import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission status
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  // Handle location permission
  Future<bool> handleLocationPermission(BuildContext context) async {
    // First check if location service is enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog(context);
      return false;
    }

    // Then check permission
    LocationPermission permission = await checkLocationPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestLocationPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, please enable them in app settings',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );

      // Open app settings so user can enable permissions
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  // Get current position
  Future<Position?> getCurrentPosition(BuildContext context) async {
    final hasPermission = await handleLocationPermission(context);
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  // Show dialog when location service is disabled
  void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Location services are disabled. Please enable the services to use this feature.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }
}