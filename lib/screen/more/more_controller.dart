import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class MoreController {
  final ApiService _apiService;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> showCheckInButton = ValueNotifier<bool>(false);

  // Add a new ValueNotifier to track check-in status
  final ValueNotifier<bool> isCheckedIn = ValueNotifier<bool>(false);

  // Make menuItems a ValueNotifier so we can update it based on API response
  final ValueNotifier<List<MenuItem>> menuItemsNotifier;

  // Initial list of menu items
  final List<MenuItem> _initialMenuItems = [
    MenuItem(
      icon: Icons.person,
      title: "Profile",
      route: "/profile",
      iconColor: Colors.blue,
    ),
    MenuItem(
      icon: Icons.contact_phone,
      title: "Contact",
      route: "/contact",
      iconColor: Colors.blue,
    ),
    MenuItem(
      icon: Icons.school,
      title: "Trainings",
      route: "/trainings",
      iconColor: Colors.blue,
    ),
    MenuItem(
      icon: Icons.send,
      title: "Send Request",
      route: "/send-request",
      iconColor: Colors.blue,
    ),
    MenuItem(
      icon: Icons.quiz,
      title: "Quiz Result",
      route: "/quiz-result",
      iconColor: Colors.blue,
    ),
    MenuItem(
      icon: Icons.logout,
      title: "Log Out",
      route: "/logout",
      iconColor: Colors.red,
    ),
  ];
  MoreController({ApiService? apiService})
      : _apiService = apiService ??
      ApiService(ApiClient(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      })),
        menuItemsNotifier = ValueNotifier<List<MenuItem>>([]) {
    // Initialize the menuItems notifier with the initial list
    menuItemsNotifier.value = List.from(_initialMenuItems);
  }

  // Method to initialize with token
  Future<void> _initializeWithToken() async {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
      debugPrint('Token set in API client: $token');
    } else {
      debugPrint('No token found in SharedPreferences');
    }
  }

  // Method to fetch the check-in button status
  Future<void> fetchCheckInButtonStatus() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Initialize with token before making the API call
      await _initializeWithToken();

      final response = await _apiService.getCheckInButton();

      // Log the response
      debugPrint('Check-in button API response: $response');

      // Check if we should show the check-in button
      // FIXED: Check the boolean value, not string
      final shouldShowCheckIn = response['show_checkin'] == true;

      // Check if user is already checked in
      final isAlreadyCheckedIn = response['show_checkout'] == true;
      isCheckedIn.value = isAlreadyCheckedIn;

      showCheckInButton.value = shouldShowCheckIn;

      // Update the menu items based on API response
      if (shouldShowCheckIn) {
        // Create a copy of the current menu items
        final updatedMenuItems = List<MenuItem>.from(menuItemsNotifier.value);

        // Get the title for the menu item based on check-in status
        final buttonTitle = isAlreadyCheckedIn ? "Check Out" : "Check In";

        // Check if the Check In/Out menu item already exists
        final checkItemIndex = updatedMenuItems.indexWhere(
                (item) => item.title == "Check In" || item.title == "Check Out"
        );

        if (checkItemIndex != -1) {
          // Update existing button title
          updatedMenuItems[checkItemIndex] = MenuItem(
            icon: Icons.location_on,
            title: buttonTitle,
            route: "/check-in", // Keep the same route
            iconColor: Colors.blue,
          );
        } else {
          // Find the index of the Trainings item
          final trainingIndex = updatedMenuItems.indexWhere(
                  (item) => item.title == "Trainings"
          );

          // Insert Check In/Out item after Trainings
          if (trainingIndex != -1) {
            updatedMenuItems.insert(trainingIndex + 1, MenuItem(
              icon: Icons.location_on,
              title: buttonTitle,
              route: "/check-in",
              iconColor: Colors.blue,
            ));
          }
        }

        // Update the menu items notifier
        menuItemsNotifier.value = updatedMenuItems;
      } else {
        // If we shouldn't show the check-in button, remove it from the menu
        final updatedMenuItems = menuItemsNotifier.value.where(
                (item) => item.title != "Check In" && item.title != "Check Out"
        ).toList();

        menuItemsNotifier.value = updatedMenuItems;
      }
    } catch (e) {
      debugPrint('Error fetching check-in button status: $e');

      // Handle the error - if it's an auth error, use default menu
      if (e.toString().contains('Unauthorized') || e.toString().contains('401')) {
        debugPrint('Using default menu items due to authentication error');
        menuItemsNotifier.value = List.from(_initialMenuItems);

        // We'll set the error message for logging purposes, but UI will hide this specific error
        errorMessage.value = "Authentication error: ${e.toString()}";
      } else {
        // For other errors, set the error message normally
        errorMessage.value = "Failed to fetch check-in button status: ${e.toString()}";
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Method to handle check in/out based on current status
  Future<void> handleCheckInOut(BuildContext context) async {
    if (isCheckedIn.value) {
      // If already checked in, perform checkout
      await performCheckOut(context);
    } else {
      // Otherwise, perform check in
      await performLocationCheckIn(context);
    }

    // Refresh the button status after check in/out
    await fetchCheckInButtonStatus();
  }

  // Method to perform check-in with location
  Future<void> performLocationCheckIn(BuildContext context) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationMessage(context,
            'Location services are disabled. Please enable them to check in.',
            Colors.orange
        );
        return;
      }

      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationMessage(context,
              'Location permissions are denied. Please grant them to check in.',
              Colors.orange
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationMessage(context,
            'Location permissions are permanently denied. Please enable them in settings.',
            Colors.red
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Define the target location coordinates
      const double targetLatitude = 43.595310;
      const double targetLongitude = -79.640579;

      // Calculate distance between current position and target location (in meters)
      double distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          targetLatitude,
          targetLongitude
      );

      // Check if user is within 50 meter radius
      if (distanceInMeters > 50) {
        _showLocationMessage(context,
            'You are out of location. You must be within 50 meters of the designated area to check in.',
            Colors.red
        );
        isLoading.value = false;
        return;
      }

      // Initialize with token before making the API call
      await _initializeWithToken();

      // Prepare data for API call
      Map<String, dynamic> checkInData = {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };

      // Call the API
      final response = await _apiService.checkIn(checkInData);

      // Log the response
      debugPrint('Check-in API response: $response');

      // Show result to user
      if (response['success'] == true) {
        // Update check-in status
        isCheckedIn.value = true;

        // Update button in the menu
        _updateCheckButton("Check Out");

        _showLocationMessage(context,
            response['message'] ?? 'Successfully checked in!',
            Colors.green
        );
      } else {
        _showLocationMessage(context,
            response['message'] ?? 'Failed to check in. Please try again.',
            Colors.red
        );
      }
    } catch (e) {
      debugPrint('Error during check-in process: $e');
      _showLocationMessage(context,
          'Error during check-in: ${e.toString()}',
          Colors.red
      );
    } finally {
      isLoading.value = false;
    }
  }

  // New method to perform checkout
  Future<void> performCheckOut(BuildContext context) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Define the target location coordinates
      const double targetLatitude = 43.595310;
      const double targetLongitude = -79.640579;

      // Calculate distance between current position and target location (in meters)
      double distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          targetLatitude,
          targetLongitude
      );

      // Check if user is within 50 meter radius
      if (distanceInMeters > 50) {
        _showLocationMessage(context,
            'You are out of location. You must be within 50 meters of the designated area to check in.',
            Colors.red
        );
        isLoading.value = false;
        return;
      }

      // Initialize with token before making the API call
      await _initializeWithToken();

      // Prepare data for API call
      Map<String, dynamic> checkOutData = {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };

      // Call the checkout API
      final response = await _apiService.checkOut(checkOutData);

      // Log the response
      debugPrint('Check-out API response: $response');

      // Show result to user
      if (response['success'] == true) {
        // Update check-in status
        isCheckedIn.value = false;

        // Update button in the menu
        _updateCheckButton("Check In");

        _showLocationMessage(context,
            response['message'] ?? 'Successfully checked out!',
            Colors.green
        );
      } else {
        _showLocationMessage(context,
            response['message'] ?? 'Failed to check out. Please try again.',
            Colors.red
        );
      }
    } catch (e) {
      debugPrint('Error during checkout process: $e');
      _showLocationMessage(context,
          'Error during checkout: ${e.toString()}',
          Colors.red
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to update the Check In/Out button
  void _updateCheckButton(String newTitle) {
    final updatedMenuItems = List<MenuItem>.from(menuItemsNotifier.value);

    final checkItemIndex = updatedMenuItems.indexWhere(
            (item) => item.title == "Check In" || item.title == "Check Out"
    );

    if (checkItemIndex != -1) {
      updatedMenuItems[checkItemIndex] = MenuItem(
        icon: Icons.location_on,
        title: newTitle,
        route: "/check-in", // Keep the same route
        iconColor: Colors.blue,
      );

      menuItemsNotifier.value = updatedMenuItems;
    }
  }

  // Helper method to show location status message
  void _showLocationMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Method to navigate to specific route
  void navigateTo(BuildContext context, String route) {
    if (route == "/logout") {
      // Show confirmation dialog for logout
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Logout"),
                onPressed: () {
                  // Handle logout logic here
                  // For example:
                  // authService.logout();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          );
        },
      );
    }
    else if (route == "/check-in") {
      // Instead of directly performing check-in, handle based on current status
      handleCheckInOut(context);
    } else {
      // Navigate to the route
      Navigator.of(context).pushNamed(route);
    }
  }

  // Clean up resources
  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    showCheckInButton.dispose();
    isCheckedIn.dispose();
    menuItemsNotifier.dispose();
  }
}

// Model class for menu items
class MenuItem {
  final IconData icon;
  final String title;
  final String route;
  final Color iconColor;

  MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.iconColor,
  });
}