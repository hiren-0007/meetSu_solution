import 'package:flutter/material.dart';

class HomeController {
  // Observable states
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  // Change bottom navigation tab
  void changeTab(int index) {
    selectedIndex.value = index;
  }

  // Open drawer menu
  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
    debugPrint("Open drawer menu");
  }

  // Open notifications
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
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
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

  // Possible additional methods for your home screen:

  // Refresh dashboard data
  Future<void> refreshDashboardData() async {
    // Fetch updated data from API
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("Dashboard data refreshed");
  }

  // Handle profile tap
  void navigateToProfile(BuildContext context) {
    // Navigate to profile screen
    debugPrint("Navigate to profile screen");
  }

  // Handle settings tap
  void navigateToSettings(BuildContext context) {
    // Navigate to settings screen
    debugPrint("Navigate to settings screen");
  }

  // Log out user
  void logout(BuildContext context) {
    // Perform logout actions and navigate to login screen
    debugPrint("Logging out user");
  }

  // Dispose resources
  void dispose() {
    selectedIndex.dispose();
  }
}
