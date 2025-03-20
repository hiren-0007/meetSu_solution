import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _isLoading = false;
  String _message = '';
  Color _messageColor = Colors.black;

  // Target location coordinates - replace with your actual coordinates
  final double _targetLatitude = 37.4220; // Example latitude
  final double _targetLongitude = -122.0841; // Example longitude
  final double _radiusInMeters = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Check In'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 8,
            left: 7,
            right: 7,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: AppTheme.headerContainerDecoration,
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppTheme.primaryColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Check In at Work Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'You need to be within 50 meters of your work location to check in successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_message.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: _messageColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _messageColor.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _messageColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _checkLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Check In Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkLocation() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _message = 'Location services are disabled. Please enable them to check in.';
          _messageColor = Colors.orange;
        });
        return;
      }

      // Check for permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _message = 'Location permissions are denied. Please grant them to check in.';
            _messageColor = Colors.orange;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _message = 'Location permissions are permanently denied. Please enable them in settings.';
          _messageColor = Colors.red;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculate distance between current position and target location
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _targetLatitude,
        _targetLongitude,
      );

      // Check if user is within the radius
      if (distanceInMeters <= _radiusInMeters) {
        setState(() {
          _message = 'You are ready to work! Successfully checked in.';
          _messageColor = Colors.green;
        });
        debugPrint('ready to work');
      } else {
        setState(() {
          _message = 'You are out of location. Please move closer to your work location to check in.';
          _messageColor = Colors.red;
        });
        debugPrint('out of location');
      }
    } catch (e) {
      setState(() {
        _message = 'Error checking location: $e';
        _messageColor = Colors.red;
      });
      debugPrint('Error checking location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}