import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/auth/login/login_screen.dart';
import 'package:meetsu_solutions/screen/more/contact/contact_screen.dart';
import 'package:meetsu_solutions/screen/more/profile/profile_screen.dart';
import 'package:meetsu_solutions/screen/more/quiz/quiz_result_screen.dart';
import 'package:meetsu_solutions/screen/more/request/send_request_screen.dart';
import 'package:meetsu_solutions/screen/more/training/training_screen.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefsService.init();

  runApp(const JobPortalApp());
}

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Job Portal App',
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: LoginScreen(),
      routes: {
        '/profile': (context) => const ProfileScreen(),
        '/contact': (context) => const ContactScreen(),
        '/trainings': (context) => const TrainingScreen(),
        '/send-request': (context) => const SendRequestScreen(),
        '/quiz-result': (context) => const QuizResultScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}