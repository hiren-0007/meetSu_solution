import 'package:flutter/material.dart';

class MoreController {
  // ValueNotifiers for reactive state management
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // List of menu items
  final List<MenuItem> menuItems = [
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
      iconColor: Colors.blue,
    ),
  ];

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