import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/services/firebase/firebase_messaging_service.dart';

class HomeController {
  final ApiService _apiService;
  final FirebaseMessagingService _firebaseMessagingService = FirebaseMessagingService();
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  final ValueNotifier<bool> showQuiz = ValueNotifier<bool>(false);
  final ValueNotifier<String> quizMessage1 = ValueNotifier<String>("");
  final ValueNotifier<String> quizMessage2 = ValueNotifier<String>("");

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

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
    debugPrint("🔍 Open drawer menu");
  }

  Future<void> openNotifications(BuildContext context) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      debugPrint("📢 Fetching quiz notification data...");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final token = SharedPrefsService.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        _apiService.client.addAuthToken(token);
      }

      final quizData = await _apiService.getShowQuiz();
      debugPrint("📥 Quiz API Response: $quizData");

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        showQuiz.value = quizData['show'] == true;
        quizMessage1.value = quizData['message1'] ?? "";
        quizMessage2.value = quizData['message2'] ?? "";

        if (showQuiz.value) {
          Navigator.of(context).pushNamed('/quiz');
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                title: const Text("Upcoming Quiz"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quizMessage1.value),
                    if (quizMessage2.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(quizMessage2.value),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }

      debugPrint("✅ Quiz notification data fetched: $quizData");
    } catch (e) {
      errorMessage.value = "Failed to load quiz information: ${e.toString()}";
      debugPrint("❌ Error in openNotifications: $e");

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

      // await _apiService.getUserLogout();
      debugPrint("✅ Logout API call successful");

      await SharedPrefsService.instance.clear();
      debugPrint("✅ Local preferences cleared");

      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
    debugPrint("🧹 Disposing HomeController resources");
    selectedIndex.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    showQuiz.dispose();
    quizMessage1.dispose();
    quizMessage2.dispose();
  }
}