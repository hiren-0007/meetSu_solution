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
    // Make sure SharedPrefs is initialized
    await SharedPrefsService.init();

    // Add a small delay to show splash screen
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Check if user has a valid token
    final token = SharedPrefsService.instance.getAccessToken();

    if (token != null && token.isNotEmpty) {
      // Valid token exists, navigate to home
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen())
          // MaterialPageRoute(builder: (_) => const ClientHomeScreen())
      );
    } else {
      // No valid token, go to login
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo or app name
            Image.asset('assets/images/logo.png', height: 120),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}