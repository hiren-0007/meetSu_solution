import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/c_home/clint_home_screen.dart';
import '../../services/pref/shared_prefs_service.dart';
import '../auth/login/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      await SharedPrefsService.init();

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      final token = SharedPrefsService.instance.getAccessToken();

      if (token != null && token.isNotEmpty) {
        final loginType = SharedPrefsService.instance.getLoginType();

        if (loginType != null && loginType.isNotEmpty) {
          _navigateToHomeScreen(loginType);
        } else {
          _navigateToLogin();
        }
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen())
    );
  }

  /// Navigate to appropriate home screen based on login type
  void _navigateToHomeScreen(String loginType) {
    Widget destinationScreen;
    String screenName;

    switch (loginType.toLowerCase().trim()) {
      case 'applicant':
        destinationScreen = const HomeScreen();
        screenName = "HomeScreen (Applicant)";
        break;
      case 'client':
        destinationScreen = const ClientHomeScreen();
        screenName = "ClientHomeScreen (Client)";
        break;
      default:
        _clearDataAndGoToLogin();
        return;
    }

    print("🚀 Navigating to: $screenName");
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destinationScreen)
    );
  }

  /// Clear stored data and navigate to login (for unknown login types)
  Future<void> _clearDataAndGoToLogin() async {
    try {
      await SharedPrefsService.instance.clear();
    } catch (e) {
      print("❌ Error clearing data: $e");
    }

    if (mounted) {
      _navigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo or app name
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "MEETsu Solutions",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Loading...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}