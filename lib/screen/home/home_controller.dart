import 'package:flutter/material.dart';

import '../../services/api/api_client.dart';
import '../../services/api/api_service.dart';
import '../../services/pref/shared_prefs_service.dart';

class HomeController {
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
    debugPrint("Open drawer menu");
  }

  void openNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text("Upcoming Quiz"),
          content: Text("Quiz will be on every Sunday at 12:00 PM"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              child: Text(
                "Close",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    debugPrint("Open notifications");
  }

  Future<void> refreshDashboardData() async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("Dashboard data refreshed");
  }

  void navigateToProfile(BuildContext context) {
    debugPrint("Navigate to profile screen");
  }

  void navigateToSettings(BuildContext context) {
    debugPrint("Navigate to settings screen");
  }

  Future<void> logout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final apiService = ApiService(ApiClient());
      final token = SharedPrefsService.instance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        apiService.client.addAuthToken(token);
      }

      await apiService.getUserLogout();

      await SharedPrefsService.instance.clear();

      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void dispose() {
    selectedIndex.dispose();
  }
}
