import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meetsu_solutions/screen/auth/login/login_screen.dart';
import 'package:meetsu_solutions/screen/more/contact/contact_screen.dart';
import 'package:meetsu_solutions/screen/more/profile/profile_screen.dart';
import 'package:meetsu_solutions/screen/more/quiz/quiz_result_screen.dart';
import 'package:meetsu_solutions/screen/more/request/send_request_screen.dart';
import 'package:meetsu_solutions/screen/more/training/training_screen.dart';
import 'package:meetsu_solutions/services/connectivity/connectivity_service.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefsService.init();

  ConnectivityService().initialize();

  await Firebase.initializeApp();

  await setupFirebaseMessaging();

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
      ),
    );
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Background Message Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('💥 Background Message: ${message.messageId}');
}

// Setup Function
Future<void> setupFirebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // iOS permission
  await FirebaseMessaging.instance.requestPermission();

  // Get FCM token
  String? token = await FirebaseMessaging.instance.getToken();
  print('🔥 FCM Token: $token');

  // Foreground Notification Handling
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'MEETSu Solutions',
            'Default',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
}
