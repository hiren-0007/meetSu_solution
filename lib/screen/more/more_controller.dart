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

  final ValueNotifier<bool> isCheckedIn = ValueNotifier<bool>(false);

  final ValueNotifier<List<MenuItem>> menuItemsNotifier;

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
    menuItemsNotifier.value = List.from(_initialMenuItems);
  }

  Future<void> _initializeWithToken() async {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
      debugPrint('Token set in API client: $token');
    } else {
      debugPrint('No token found in SharedPreferences');
    }
  }

  Future<void> fetchCheckInButtonStatus() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _initializeWithToken();

      final response = await _apiService.getCheckInButton();

      debugPrint('Check-in button API response: $response');
      final shouldShowCheckIn = response['show_checkin'] == true;

      final isAlreadyCheckedIn = response['show_checkout'] == true;
      isCheckedIn.value = isAlreadyCheckedIn;

      showCheckInButton.value = shouldShowCheckIn;

      if (shouldShowCheckIn) {
        final updatedMenuItems = List<MenuItem>.from(menuItemsNotifier.value);

        final buttonTitle = isAlreadyCheckedIn ? "Check Out" : "Check In";

        final checkItemIndex = updatedMenuItems.indexWhere(
            (item) => item.title == "Check In" || item.title == "Check Out");

        if (checkItemIndex != -1) {
          updatedMenuItems[checkItemIndex] = MenuItem(
            icon: Icons.location_on,
            title: buttonTitle,
            route: "/check-in",
            iconColor: Colors.blue,
          );
        } else {
          final trainingIndex =
              updatedMenuItems.indexWhere((item) => item.title == "Trainings");

          if (trainingIndex != -1) {
            updatedMenuItems.insert(
                trainingIndex + 1,
                MenuItem(
                  icon: Icons.location_on,
                  title: buttonTitle,
                  route: "/check-in",
                  iconColor: Colors.blue,
                ));
          }
        }

        menuItemsNotifier.value = updatedMenuItems;
      } else {
        final updatedMenuItems = menuItemsNotifier.value
            .where(
                (item) => item.title != "Check In" && item.title != "Check Out")
            .toList();

        menuItemsNotifier.value = updatedMenuItems;
      }
    } catch (e) {
      debugPrint('Error fetching check-in button status: $e');

      if (e.toString().contains('Unauthorized') ||
          e.toString().contains('401')) {
        debugPrint('Using default menu items due to authentication error');
        menuItemsNotifier.value = List.from(_initialMenuItems);

        errorMessage.value = "Authentication error: ${e.toString()}";
      } else {
        errorMessage.value =
            "Failed to fetch check-in button status: ${e.toString()}";
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleCheckInOut(BuildContext context) async {
    if (isCheckedIn.value) {
      await performCheckOut(context);
    } else {
      await performLocationCheckIn(context);
    }

    await fetchCheckInButtonStatus();
  }

  Future<void> performLocationCheckIn(BuildContext context) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationMessage(
            context,
            'Location services are disabled. Please enable them to check in.',
            Colors.orange);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationMessage(
              context,
              'Location permissions are denied. Please grant them to check in.',
              Colors.orange);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationMessage(
            context,
            'Location permissions are permanently denied. Please enable them in settings.',
            Colors.red);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      const double targetLatitude = 43.595310;
      const double targetLongitude = -79.640579;

      double distanceInMeters = Geolocator.distanceBetween(position.latitude,
          position.longitude, targetLatitude, targetLongitude);

      if (distanceInMeters > 50) {
        _showLocationMessage(
            context,
            'You are out of location. You must be within 50 meters of the designated area to check in.',
            Colors.red);
        isLoading.value = false;
        return;
      }

      await _initializeWithToken();

      Map<String, dynamic> checkInData = {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };

      final response = await _apiService.checkIn(checkInData);

      debugPrint('Check-in API response: $response');

      if (response['success'] == true) {
        isCheckedIn.value = true;

        _updateCheckButton("Check Out");

        _showLocationMessage(context,
            response['message'] ?? 'Successfully checked in!', Colors.green);
      } else {
        _showLocationMessage(
            context,
            response['message'] ?? 'Failed to check in. Please try again.',
            Colors.red);
      }
    } catch (e) {
      debugPrint('Error during check-in process: $e');
      _showLocationMessage(
          context, 'Error during check-in: ${e.toString()}', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> performCheckOut(BuildContext context) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      const double targetLatitude = 43.595310;
      const double targetLongitude = -79.640579;

      double distanceInMeters = Geolocator.distanceBetween(position.latitude,
          position.longitude, targetLatitude, targetLongitude);

      if (distanceInMeters > 50) {
        _showLocationMessage(
            context,
            'You are out of location. You must be within 50 meters of the designated area to check in.',
            Colors.red);
        isLoading.value = false;
        return;
      }

      await _initializeWithToken();

      Map<String, dynamic> checkOutData = {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };

      final response = await _apiService.checkOut(checkOutData);

      debugPrint('Check-out API response: $response');

      if (response['success'] == true) {
        isCheckedIn.value = false;

        _updateCheckButton("Check In");

        _showLocationMessage(context,
            response['message'] ?? 'Successfully checked out!', Colors.green);
      } else {
        _showLocationMessage(
            context,
            response['message'] ?? 'Failed to check out. Please try again.',
            Colors.red);
      }
    } catch (e) {
      debugPrint('Error during checkout process: $e');
      _showLocationMessage(
          context, 'Error during checkout: ${e.toString()}', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void _updateCheckButton(String newTitle) {
    final updatedMenuItems = List<MenuItem>.from(menuItemsNotifier.value);

    final checkItemIndex = updatedMenuItems.indexWhere(
        (item) => item.title == "Check In" || item.title == "Check Out");

    if (checkItemIndex != -1) {
      updatedMenuItems[checkItemIndex] = MenuItem(
        icon: Icons.location_on,
        title: newTitle,
        route: "/check-in",
        iconColor: Colors.blue,
      );

      menuItemsNotifier.value = updatedMenuItems;
    }
  }

  void _showLocationMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void navigateTo(BuildContext context, String route) {
    if (route == "/logout") {
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
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          );
        },
      );
    } else if (route == "/check-in") {
      handleCheckInOut(context);
    } else {
      Navigator.of(context).pushNamed(route);
    }
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    showCheckInButton.dispose();
    isCheckedIn.dispose();
    menuItemsNotifier.dispose();
  }
}

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
