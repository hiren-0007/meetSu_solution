import 'package:flutter/material.dart';

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

  void logout(BuildContext context) {
    debugPrint("Logging out user");
  }

  // Dispose resources
  void dispose() {
    selectedIndex.dispose();
  }
}
