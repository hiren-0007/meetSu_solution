import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

class MoreController {
  final ApiService _apiService;

  // State management with ValueNotifiers
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> showCheckInButton = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isCheckedIn = ValueNotifier<bool>(false);
  final ValueNotifier<List<MenuItem>> menuItemsNotifier = ValueNotifier<List<MenuItem>>([]);

  // Cache for menu items
  static const List<MenuItem> _baseMenuItems = [
    MenuItem(
      icon: Icons.person_outline,
      title: "Profile",
      route: "/profile",
      iconColor: Colors.blue,
    ),
    MenuItem(
      icon: Icons.contact_phone_outlined,
      title: "Contact",
      route: "/contact",
      iconColor: Colors.blue,
    ),
    MenuItem(
      icon: Icons.school_outlined,
      title: "Trainings",
      route: "/trainings",
      iconColor: Colors.blue,
    ),
    MenuItem(
      icon: Icons.send_outlined,
      title: "Send Request",
      route: "/send-request",
      iconColor: Colors.blue,
    ),
    MenuItem(
      icon: Icons.quiz_outlined,
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

  // Private variables for state tracking
  bool _isInitialized = false;
  String? _cachedToken;

  MoreController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient(headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  })) {
    _initializeMenuItems();
  }

  void _initializeMenuItems() {
    menuItemsNotifier.value = List.from(_baseMenuItems);
  }

  /// Initialize API client with authentication token
  Future<bool> _initializeWithToken() async {
    if (_isInitialized && _cachedToken != null) {
      return true;
    }

    try {
      final token = SharedPrefsService.instance.getAccessToken();
      if (token?.isNotEmpty == true) {
        _apiService.client.addAuthToken(token!);
        _cachedToken = token;
        _isInitialized = true;
        debugPrint('✅ Token initialized successfully');
        return true;
      } else {
        debugPrint('⚠️ No valid token found');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Token initialization failed: $e');
      return false;
    }
  }

  /// Fetch check-in button status from API
  Future<void> fetchCheckInButtonStatus() async {
    if (isLoading.value) return; // Prevent duplicate calls

    _setLoading(true);
    _clearError();

    try {
      final hasToken = await _initializeWithToken();
      if (!hasToken) {
        debugPrint('📝 Using default menu items (no token)');
        _initializeMenuItems();
        return;
      }

      final response = await _apiService.getCheckInButton();
      debugPrint('📱 Check-in API response: $response');

      await _processCheckInResponse(response);

    } catch (e) {
      debugPrint('❌ Error fetching check-in status: $e');
      await _handleApiError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Process the check-in API response
  Future<void> _processCheckInResponse(Map<String, dynamic> response) async {
    final shouldShowCheckIn = response['show_checkin'] == true;
    final isAlreadyCheckedIn = response['show_checkout'] == true;

    showCheckInButton.value = shouldShowCheckIn;
    isCheckedIn.value = isAlreadyCheckedIn;

    if (shouldShowCheckIn) {
      _addCheckInMenuItem(isAlreadyCheckedIn);
    } else {
      _removeCheckInMenuItem();
    }
  }

  /// Add check-in/check-out menu item
  void _addCheckInMenuItem(bool isCheckedIn) {
    final buttonTitle = isCheckedIn ? "Clock Out" : "Clock In";
    final buttonIcon = isCheckedIn ? Icons.logout : Icons.login;

    final updatedMenuItems = List<MenuItem>.from(_baseMenuItems);

    // Find position to insert (after Trainings)
    final trainingIndex = updatedMenuItems.indexWhere(
            (item) => item.title == "Trainings"
    );

    final insertIndex = trainingIndex != -1 ? trainingIndex + 1 : 3;

    updatedMenuItems.insert(
      insertIndex,
      MenuItem(
        icon: buttonIcon,
        title: buttonTitle,
        route: "/clock-in",
        iconColor: isCheckedIn ? Colors.orange : Colors.green,
      ),
    );

    menuItemsNotifier.value = updatedMenuItems;
    debugPrint('✅ Added $buttonTitle menu item');
  }

  /// Remove check-in/check-out menu item
  void _removeCheckInMenuItem() {
    final updatedMenuItems = _baseMenuItems
        .where((item) =>
    item.title != "Clock In" &&
        item.title != "Clock Out")
        .toList();

    menuItemsNotifier.value = updatedMenuItems;
    debugPrint('🗑️ Removed clock-in menu item');
  }

  /// Handle check-in/check-out action
  Future<void> handleCheckInOut(BuildContext context) async {
    if (isLoading.value) return;

    try {
      if (isCheckedIn.value) {
        await performCheckOut(context);
      } else {
        await performCheckIn(context);
      }

      // Refresh menu items after action
      await fetchCheckInButtonStatus();

    } catch (e) {
      debugPrint('❌ Error in check-in/out process: $e');
      _showErrorSnackBar(context, 'Failed to process request: ${e.toString()}');
    }
  }

  /// Perform check-in operation
  Future<void> performCheckIn(BuildContext context) async {
    _setLoading(true);

    try {
      final hasToken = await _initializeWithToken();
      if (!hasToken) {
        throw Exception('Authentication required');
      }

      final position = await _getCurrentLocation();
      final checkInData = {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };

      final response = await _apiService.checkIn(checkInData);
      debugPrint('✅ Check-in response: $response');

      _updateCheckInState(response);
      _showResponseMessage(context, response, 'Clock-in completed');

    } catch (e) {
      debugPrint('❌ Check-in error: $e');
      _showErrorSnackBar(context, 'Check-in failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Perform check-out operation
  Future<void> performCheckOut(BuildContext context) async {
    _setLoading(true);

    try {
      final hasToken = await _initializeWithToken();
      if (!hasToken) {
        throw Exception('Authentication required');
      }

      final position = await _getCurrentLocation();
      final checkOutData = {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };

      final response = await _apiService.checkOut(checkOutData);
      debugPrint('✅ Check-out response: $response');

      _updateCheckInState(response);
      _showResponseMessage(context, response, 'Clock-out completed');

    } catch (e) {
      debugPrint('❌ Check-out error: $e');
      _showErrorSnackBar(context, 'Check-out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get current location with permission handling
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    //return await Geolocator.getCurrentPosition(
    //       locationSettings: AndroidSettings(
    //         accuracy: LocationAccuracy.high,
    //         distanceFilter: 0,
    //         forceLocationManager: false,
    //         intervalDuration: const Duration(seconds: 10),
    //       ),
    //     );
  }

  /// Update check-in state from API response
  void _updateCheckInState(Map<String, dynamic> response) {
    if (response.containsKey('show_checkout')) {
      isCheckedIn.value = response['show_checkout'] == true;
    }
  }

  /// Show response message to user
  void _showResponseMessage(
      BuildContext context,
      Map<String, dynamic> response,
      String defaultMessage
      ) {
    String message = _extractMessage(response) ?? defaultMessage;
    Color color = response['success'] == true ? Colors.green : Colors.orange;

    _showSnackBar(context, message, color);
  }

  /// Extract message from API response
  String? _extractMessage(Map<String, dynamic> response) {
    final messages = <String>[];

    if (response['message1']?.isNotEmpty == true) {
      messages.add(response['message1']);
    }
    if (response['message2']?.isNotEmpty == true) {
      messages.add(response['message2']);
    }

    return messages.isNotEmpty ? messages.join(' ') : null;
  }

  /// Handle API errors gracefully
  Future<void> _handleApiError(dynamic error) async {
    final errorString = error.toString();

    if (errorString.contains('Unauthorized') || errorString.contains('401')) {
      debugPrint('🔐 Authentication error - using default menu');
      _initializeMenuItems();
      // Don't show error for auth issues
    } else {
      errorMessage.value = 'Failed to load menu: $errorString';
    }
  }

  /// Navigate to different screens with proper handling
  void navigateTo(BuildContext context, String route) {
    HapticFeedback.lightImpact();

    switch (route) {
      case "/logout":
        _showLogoutDialog(context);
        break;
      case "/clock-in":
        handleCheckInOut(context);
        break;
      case "/delete":
        _showDeleteAccountDialog(context);
        break;
      default:
        Navigator.of(context).pushNamed(route);
    }
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text("Logout"),
            ],
          ),
          content: const Text("Are you sure you want to log out?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, child) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: loading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text("Logout"),
                  onPressed: loading ? null : () => _performLogout(context),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Perform logout operation
  Future<void> _performLogout(BuildContext context) async {
    _setLoading(true);

    try {
      await _initializeWithToken();
      // final response = await _apiService.getUserLogout();
      // debugPrint('👋 Logout response: $response');

      await SharedPrefsService.instance.clear();
      _resetState();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Logout failed: ${e.toString()}');
        Navigator.of(context).pop(); // Close dialog
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Show delete account dialog (placeholder)
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.red),
              SizedBox(width: 8),
              Text("Delete Account"),
            ],
          ),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar(context, 'Account deletion feature coming soon', Colors.orange);
              },
            ),
          ],
        );
      },
    );
  }

  // Utility methods
  void _setLoading(bool loading) => isLoading.value = loading;
  void _clearError() => errorMessage.value = null;

  void _showSnackBar(BuildContext context, String message, Color color) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red);
  }

  /// Reset controller state
  void _resetState() {
    _isInitialized = false;
    _cachedToken = null;
    isCheckedIn.value = false;
    showCheckInButton.value = false;
    _clearError();
    _initializeMenuItems();
  }

  /// Dispose all resources
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

  const MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.iconColor,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem &&
        other.icon == icon &&
        other.title == title &&
        other.route == route &&
        other.iconColor == iconColor;
  }

  @override
  int get hashCode {
    return icon.hashCode ^
    title.hashCode ^
    route.hashCode ^
    iconColor.hashCode;
  }

  @override
  String toString() {
    return 'MenuItem(icon: $icon, title: $title, route: $route, iconColor: $iconColor)';
  }

  /// Create a copy of MenuItem with optional parameter overrides
  MenuItem copyWith({
    IconData? icon,
    String? title,
    String? route,
    Color? iconColor,
  }) {
    return MenuItem(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      route: route ?? this.route,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}