import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class MoreController {
  final ApiService _apiService;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> showCheckInButton = ValueNotifier<bool>(false);

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
      final shouldShowCheckIn = response['data'] != null &&
          response['data']['show_checkin'] == 1;

      showCheckInButton.value = shouldShowCheckIn;

      // Update the menu items based on API response
      if (shouldShowCheckIn) {
        // Create a copy of the current menu items
        final updatedMenuItems = List<MenuItem>.from(menuItemsNotifier.value);

        // Check if the Check In menu item already exists
        final checkInExists = updatedMenuItems.any(
                (item) => item.title == "Check In"
        );

        // If it doesn't exist, add it after the Trainings item
        if (!checkInExists) {
          // Find the index of the Trainings item
          final trainingIndex = updatedMenuItems.indexWhere(
                  (item) => item.title == "Trainings"
          );

          // Insert Check In item after Trainings
          if (trainingIndex != -1) {
            updatedMenuItems.insert(trainingIndex + 1, MenuItem(
              icon: Icons.lock_clock,
              title: "Check In",
              route: "/check-in",
              iconColor: Colors.blue,
            ));

            // Update the menu items notifier
            menuItemsNotifier.value = updatedMenuItems;
          }
        }
      } else {
        // If we shouldn't show the check-in button, remove it from the menu
        final updatedMenuItems = menuItemsNotifier.value.where(
                (item) => item.title != "Check In"
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