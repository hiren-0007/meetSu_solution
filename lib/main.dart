import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meetsu_solutions/screen/auth/login/login_screen.dart';
import 'package:meetsu_solutions/screen/more/contact/contact_screen.dart';
import 'package:meetsu_solutions/screen/more/profile/profile_screen.dart';
import 'package:meetsu_solutions/screen/more/quiz/quiz_result_screen.dart';
import 'package:meetsu_solutions/screen/more/request/send_request_screen.dart';
import 'package:meetsu_solutions/screen/more/training/training_screen.dart';
import 'package:meetsu_solutions/services/connectivity/connectivity_service.dart';
import 'package:meetsu_solutions/services/firebase/firebase_messaging_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  await SharedPrefsService.init();

  // Initialize connectivity service
  ConnectivityService().initialize();

  try {
    // Initialize Firebase only once with options
    await Firebase.initializeApp();
    print('Firebase core initialized successfully');

    // Initialize Firebase Messaging
    await FirebaseMessagingService().initializeWithoutFirebase();
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const JobPortalApp());
}

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: MaterialApp(
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
        navigatorKey: GlobalKey<NavigatorState>(),
      ),
    );
  }
}