import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/c_home/clint_home_screen.dart';
import 'package:meetsu_solutions/clint/c_screen/c_more/analytics/daily/daily_analytics_screen.dart';
import 'package:meetsu_solutions/clint/c_screen/c_more/analytics/weekly/weekly_analytics_screen.dart';
import 'package:meetsu_solutions/clint/c_screen/c_more/c_profile/clint_profile_screen.dart';
import 'package:meetsu_solutions/screen/auth/login/login_screen.dart';
import 'package:meetsu_solutions/screen/home/home_screen.dart';
import 'package:meetsu_solutions/screen/more/contact/contact_screen.dart';
import 'package:meetsu_solutions/screen/more/profile/profile_screen.dart';
import 'package:meetsu_solutions/screen/more/quiz/quiz_result_screen.dart';
import 'package:meetsu_solutions/screen/more/request/send_request_screen.dart';
import 'package:meetsu_solutions/screen/more/training/training_screen.dart';
import 'package:meetsu_solutions/screen/quiz/quiz_screen.dart';
import 'package:meetsu_solutions/screen/splash/splash_screen.dart';
import 'package:meetsu_solutions/services/connectivity/connectivity_service.dart';
import 'package:meetsu_solutions/services/firebase/firebase_messaging_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Create a global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  await SharedPrefsService.init();

  // Initialize connectivity service
  ConnectivityService().initialize();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('Firebase core initialized successfully');

    // Initialize FCM background handler
    await FirebaseMessagingService().initialize();

    // 🔔 Request notification permission here
    await requestNotificationPermission();

  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const JobPortalApp());
}

// 🔹 Request iOS Notification Permissions
Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('🔔 Permission status: ${settings.authorizationStatus}');
}

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '',
        theme: ThemeData(
          primaryColor: const Color(0xFF6C63FF),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
        navigatorKey: navigatorKey,
        routes: {
          '/profile': (context) => const ProfileScreen(),
          '/clint-profile': (context) => const ClientProfileScreen(),
          '/contact': (context) => const ContactScreen(),
          '/trainings': (context) => const TrainingScreen(),
          '/send-request': (context) => const SendRequestScreen(),
          '/quiz-result': (context) => const QuizResultScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => const HomeScreen(),
          // '/home': (context) => const ClientHomeScreen(),
          '/quiz': (context) => const QuizScreen(),
          '/analytics/daily': (context) => const DailyAnalyticsScreen(),
          '/analytics/weekly': (context) => const WeeklyAnalyticsScreen(),
        },
      ),
    );
  }
}
