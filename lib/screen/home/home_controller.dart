import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/services/firebase/firebase_messaging_service.dart';

class HomeController {
  final ApiService _apiService;
  final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService();

  // UI State Management
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Quiz State Management
  final ValueNotifier<bool> showQuiz = ValueNotifier<bool>(false);
  final ValueNotifier<String> quizMessage1 = ValueNotifier<String>("");
  final ValueNotifier<String> quizMessage2 = ValueNotifier<String>("");

  // Clock-In State Management
  final ValueNotifier<bool> isClockInDialogLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showCheckInButton = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isCheckedIn = ValueNotifier<bool>(false);

  // Private State Variables
  bool _isClockInInitialized = false;
  String? _cachedToken;
  bool _isClockInLoading = false;

  // Dialog Management Flags
  bool _dialogIsVisible = false;
  bool _isQuizApiInProgress = false;
  bool _quizDialogShown = false;

  HomeController({ApiService? apiService})
      : _apiService = apiService ?? ApiService(ApiClient()) {
    initialize();
  }

  void initialize() {
    final token = SharedPrefsService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _apiService.client.addAuthToken(token);
    }
    _sendFcmTokenOnHomeLoad();
  }

  Future<void> _sendFcmTokenOnHomeLoad() async {
    try {
      debugPrint("🔥 Sending FCM token on home page load...");
      await _firebaseMessagingService.sendTokenToServerAfterLogin();
      debugPrint("✅ FCM token sent successfully on home load");
    } catch (e) {
      debugPrint("❌ Error sending FCM token on home load: $e");
    }
  }

  Future<bool> _initializeClockInWithToken() async {
    if (_isClockInInitialized && _cachedToken != null) {
      return true;
    }

    try {
      final token = SharedPrefsService.instance.getAccessToken();
      if (token?.isNotEmpty == true) {
        _apiService.client.addAuthToken(token!);
        _cachedToken = token;
        _isClockInInitialized = true;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('❌ Clock-in token initialization failed: $e');
      return false;
    }
  }

  // Navigation Methods
  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
    debugPrint("🔍 Open drawer menu");
  }

  // Quiz Management
  Future<void> openNotifications(BuildContext context,
      {bool fromNotification = false}) async {
    // Prevention logic
    if (_isQuizApiInProgress) {
      debugPrint("🚫 Quiz API already in progress, skipping...");
      return;
    }

    if (_quizDialogShown && !fromNotification) {
      debugPrint("🚫 Quiz dialog already shown, skipping...");
      return;
    }

    _isQuizApiInProgress = true;

    // Reset quiz flags for manual execution
    if (!fromNotification) {
      _resetQuizFlags();
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      debugPrint("📢 Fetching quiz notification data...");

      // Show loading dialog only if not from notification
      if (!fromNotification && !_dialogIsVisible) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      final token = SharedPrefsService.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        _apiService.client.addAuthToken(token);
      }

      final quizData = await _apiService.getShowQuiz();
      debugPrint("📥 Quiz API Response: $quizData");

      // Close loading dialog only if it was shown
      if (context.mounted && !fromNotification && !_dialogIsVisible) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        showQuiz.value = quizData['show'] == true;
        quizMessage1.value = quizData['message1'] ?? "";
        quizMessage2.value = quizData['message2'] ?? "";

        // Show integrated dialog
        await _showIntegratedQuizDialog(context, quizData);
        _quizDialogShown = true;
      }

      debugPrint("✅ Quiz notification data fetched: $quizData");
    } catch (e) {
      errorMessage.value = "Failed to load quiz information: ${e.toString()}";
      debugPrint("❌ Error in openNotifications: $e");

      if (context.mounted) {
        // Close loading dialog if it exists
        if (!fromNotification && !_dialogIsVisible) {
          Navigator.of(context).pop();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.value ?? "Unknown error occurred"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isLoading.value = false;
      _isQuizApiInProgress = false;
    }
  }

  Future<void> _showIntegratedQuizDialog(
      BuildContext context, Map<String, dynamic> quizData) async {
    if (_dialogIsVisible) {
      debugPrint("🚫 Dialog already visible, skipping quiz dialog...");
      return;
    }

    _dialogIsVisible = true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              Icon(
                showQuiz.value ? Icons.quiz : Icons.schedule,
                color: showQuiz.value ? Colors.green : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                showQuiz.value ? "Quiz Available!" : "Upcoming Quiz",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showQuiz.value) const Text("You have a new quiz available!"),
              if (!showQuiz.value && quizMessage1.value.isNotEmpty)
                Text(quizMessage1.value),
              if (!showQuiz.value && quizMessage2.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(quizMessage2.value),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint("Later button clicked");
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text("Later"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: showQuiz.value ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                debugPrint(
                    "${showQuiz.value ? 'Take Quiz' : 'OK'} button clicked");
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(showQuiz.value ? "Take Quiz" : "OK"),
            ),
          ],
        );
      },
    );

    _dialogIsVisible = false;

    if (result == true && showQuiz.value && context.mounted) {
      Navigator.of(context).pushNamed('/quiz');
    }

    debugPrint("Quiz dialog closed");
  }

  void _resetQuizFlags() {
    _quizDialogShown = false;
    _isQuizApiInProgress = false;
    debugPrint("🔄 Quiz flags reset");
  }

  // Public method for manual quiz reset
  void resetQuizFlags() {
    _resetQuizFlags();
    debugPrint("🔄 Public quiz flags reset called");
  }

  // Clock-In Dialog Management
  Future<void> showClockInDialog(BuildContext context) async {
    debugPrint(
        "📞 showClockInDialog called, _dialogIsVisible: $_dialogIsVisible");

    if (_dialogIsVisible) {
      debugPrint("⚠️ Dialog already visible, force closing and retrying...");
      forceCloseAllDialogs(context);

      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted && !_dialogIsVisible) {
        await _showClockInDialog(context);
      }
      return;
    }

    await _showClockInDialog(context);
  }

  Future<void> _showClockInDialog(BuildContext context) async {
    if (_dialogIsVisible) {
      debugPrint("🚫 Dialog already showing, skipping...");
      return;
    }

    debugPrint("🎯 Showing Clock-in dialog");
    _dialogIsVisible = true;

    // Reset loading states
    isClockInDialogLoading.value = false;
    showCheckInButton.value = false;
    isCheckedIn.value = false;

    // FIRST: Fetch check-in status from API
    try {
      await _fetchCheckInButtonStatus();
    } catch (e) {
      debugPrint("❌ Error fetching check-in status: $e");
      _dialogIsVisible = false;
      return;
    }

    if (!context.mounted) {
      _dialogIsVisible = false;
      return;
    }

    // THEN: Show dialog based on API response
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                "Clock-In",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: ValueListenableBuilder<bool>(
            valueListenable: isClockInDialogLoading,
            builder: (context, loading, child) {
              if (loading) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Loading..."),
                  ],
                );
              }

              return ValueListenableBuilder<bool>(
                valueListenable: showCheckInButton,
                builder: (context, showButton, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: isCheckedIn,
                    builder: (context, checkedIn, child) {
                      // Case 1: Already checked in (show_checkout = true)
                      if (checkedIn) {
                        return const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 48),
                            SizedBox(height: 16),
                            Text(
                              'You are already checked in!',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      }
                      // Case 2: Can check in (show_checkin = true)
                      else if (showButton) {
                        return const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.blue, size: 48),
                            SizedBox(height: 16),
                            Text(
                              'Ready to check in?',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'We will use your current location for check-in.',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        );
                      }
                      // Case 3: Cannot check in (show_checkin = false)
                      else {
                        return const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule,
                                color: Colors.orange, size: 48),
                            SizedBox(height: 16),
                            Text(
                              'You are not scheduled today or check-in is not available.',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Please contact your supervisor for more information.',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint("❌ Cancel button clicked");
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text("Cancel"),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: showCheckInButton,
              builder: (context, showButton, child) {
                return ValueListenableBuilder<bool>(
                  valueListenable: isCheckedIn,
                  builder: (context, checkedIn, child) {
                    // Show "Check In" button ONLY when showCheckInButton is true
                    if (showButton && !checkedIn) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          debugPrint(
                              "✅ Check In button clicked - calling _performCheckIn");
                          // Close the main dialog first
                          Navigator.of(dialogContext).pop(true);

                          // Add small delay to ensure dialog is closed
                          await Future.delayed(
                              const Duration(milliseconds: 100));

                          // Then call check-in with fresh context
                          if (context.mounted) {
                            await _handleCheckIn(context);
                          }
                        },
                        child: const Text("Check In"),
                      );
                    }
                    // For all other cases (not scheduled, already checked in), show OK button
                    else {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          debugPrint("✅ OK button clicked");
                          Navigator.of(dialogContext).pop(true);
                        },
                        child: const Text("OK"),
                      );
                    }
                  },
                );
              },
            ),
          ],
        );
      },
    );

    _dialogIsVisible = false;
    debugPrint("🔚 Clock-in dialog closed with result: $result");
  }

  void resetClockInFlags() {
    _dialogIsVisible = false;
    debugPrint("🔄 Clock-in dialog flags reset");
  }

  // Utility Methods
  void forceCloseAllDialogs(BuildContext context) {
    try {
      if (_dialogIsVisible) {
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.isFirst);
      }
      _dialogIsVisible = false;
      _resetQuizFlags();
      debugPrint("All dialogs force closed");
    } catch (e) {
      debugPrint("Error force closing dialogs: $e");
    }
  }

  Future<void> _handleCheckIn(BuildContext context) async {
    if (_isClockInLoading) return;

    _isClockInLoading = true;

    // Store dialog context for later use
    BuildContext? loadingDialogContext;

    try {
      debugPrint("🔄 Starting check-in process...");

      // Show loading dialog and store its context
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          loadingDialogContext = dialogContext; // Store context
          return const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Checking in..."),
              ],
            ),
          );
        },
      );

      // Call the check-in API
      await _performCheckIn(context);
      debugPrint("✅ Check-in API completed");

      // Refresh status to get updated data
      await _fetchCheckInButtonStatus();
      debugPrint("✅ Status refreshed");
    } catch (e) {
      debugPrint("❌ Check-in failed: $e");
      _showErrorSnackBar(context, 'Failed to process request: ${e.toString()}');
    } finally {
      // Close loading dialog using stored context
      debugPrint("🔚 Attempting to close loading dialog...");
      try {
        if (loadingDialogContext != null && loadingDialogContext!.mounted) {
          Navigator.of(loadingDialogContext!).pop();
          debugPrint("✅ Loading dialog closed using stored context");
        } else if (context.mounted) {
          // Fallback: try with original context
          Navigator.of(context).pop();
          debugPrint("✅ Loading dialog closed using fallback context");
        }
      } catch (e) {
        debugPrint("❌ Error closing dialog: $e");
        // Force close all dialogs as last resort
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst || !route.hasActiveRouteBelow);
          debugPrint("🔧 Force closed dialogs");
        }
      }

      _isClockInLoading = false;
      debugPrint("🔄 Check-in process completed");
    }
  }

  Future<void> _performCheckIn(BuildContext context) async {
    try {
      final hasToken = await _initializeClockInWithToken();
      if (!hasToken) {
        throw Exception('Authentication required');
      }

      final position = await _getCurrentLocation();
      final checkInData = {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };

      debugPrint("📍 Check-in data: $checkInData");
      final response = await _apiService.checkIn(checkInData);
      debugPrint("📥 Check-in response: $response");

      _updateCheckInState(response);

      // Show success message
      _showResponseMessage(
          context, response, 'Clock-in completed successfully');
    } catch (e) {
      debugPrint("❌ Check-in error: $e");
      throw e; // Re-throw to be handled by _handleCheckIn
    }
  }

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
  }

  Future<void> _fetchCheckInButtonStatus() async {
    if (isClockInDialogLoading.value) return;

    isClockInDialogLoading.value = true;

    try {
      final hasToken = await _initializeClockInWithToken();
      if (!hasToken) {
        showCheckInButton.value = false;
        return;
      }

      final response = await _apiService.getCheckInButton();
      debugPrint("✅ Check-in button status response: $response");
      await _processCheckInResponse(response);
    } catch (e) {
      showCheckInButton.value = false;
      debugPrint('❌ Error fetching check-in status: $e');
    } finally {
      isClockInDialogLoading.value = false;
    }
  }

  Future<void> _processCheckInResponse(Map<String, dynamic> response) async {
    final shouldShowCheckIn = response['show_checkin'] == true;
    final isAlreadyCheckedIn = response['show_checkout'] == true;

    showCheckInButton.value = shouldShowCheckIn && !isAlreadyCheckedIn;
    isCheckedIn.value = isAlreadyCheckedIn;

    debugPrint(
        "✅ Processed response - Show Check-in: ${showCheckInButton.value}, Is Checked In: ${isCheckedIn.value}");
  }

  void _updateCheckInState(Map<String, dynamic> response) {
    if (response.containsKey('show_checkin')) {
      isCheckedIn.value = response['show_checkin'] == true;
    }
  }

  // UI Helper Methods
  void _showResponseMessage(
    BuildContext context,
    Map<String, dynamic> response,
    String defaultMessage,
  ) {
    String message = _extractMessage(response) ?? defaultMessage;
    Color color = response['success'] == true ? Colors.green : Colors.orange;
    _showSnackBar(context, message, color);
  }

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

  // Dashboard Methods
  Future<void> refreshDashboardData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      debugPrint("🔄 Refreshing dashboard data...");
      await Future.delayed(const Duration(seconds: 1));
      await _sendFcmTokenOnHomeLoad();
      debugPrint("✅ Dashboard data refreshed");
    } catch (e) {
      errorMessage.value = "Failed to refresh dashboard data: ${e.toString()}";
      debugPrint("❌ Error refreshing dashboard data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToProfile(BuildContext context) {
    debugPrint("👤 Navigate to profile screen");
  }

  void navigateToSettings(BuildContext context) {
    debugPrint("⚙️ Navigate to settings screen");
  }

  Future<void> logout(BuildContext context) async {
    try {
      debugPrint("🔑 Attempting to logout...");
      isLoading.value = true;
      errorMessage.value = null;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final token = SharedPrefsService.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        _apiService.client.addAuthToken(token);
      }

      debugPrint("✅ Logout API call successful");

      await SharedPrefsService.instance.clear();
      debugPrint("✅ Local preferences cleared");

      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
        debugPrint("✅ Redirected to login screen");
      }
    } catch (e) {
      errorMessage.value = "Failed to logout: ${e.toString()}";
      debugPrint("❌ Error during logout: $e");

      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.value ?? "Unknown error occurred"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    // Reset all flags
    _resetQuizFlags();
    _dialogIsVisible = false;

    // Dispose all ValueNotifiers
    selectedIndex.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    showQuiz.dispose();
    quizMessage1.dispose();
    quizMessage2.dispose();
    isClockInDialogLoading.dispose();
    showCheckInButton.dispose();
    isCheckedIn.dispose();

    debugPrint("🗑️ HomeController disposed");
  }
}
