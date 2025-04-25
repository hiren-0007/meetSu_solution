import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

import '../api/api_client.dart';
import '../api/api_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Future<void> initialize() async {
  //   await Firebase.initializeApp();
  //   await setupFirebaseMessaging();
  // }

  Future<void> initialize() async {
    try {
      // This should be called only once in your app
      await Firebase.initializeApp();
      print('Firebase initialized in service');
      await setupFirebaseMessaging();
    } catch (e) {
      print('Error initializing Firebase in service: $e');
    }
  }

  Future<void> initializeWithoutFirebase() async {
    try {
      // Skip initialization as it should be done in main.dart
      await setupFirebaseMessaging();
      print('Firebase Messaging setup complete');
    } catch (e) {
      print('Error setting up Firebase Messaging: $e');
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('💥 Background Message: ${message.messageId}');
  }

  Future<void> saveAndSendTokenToServer(String? token) async {
    if (token != null) {
      await SharedPrefsService.saveFcmToken(token);

      final accessToken = SharedPrefsService.instance.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        print('Cannot send FCM token: No access token available');
        return;
      }

      try {
        final apiClient = ApiClient();
        apiClient.addAuthToken(accessToken);
        final apiService = ApiService(apiClient);

        final deviceType = Platform.isAndroid ? '1' : Platform.isIOS ? '2' : '3';

        final tokenData = {
          'token': token,
          'device_type': deviceType
        };

        final response = await apiService.fcmToken(tokenData);

        if (response['success'] == true) {
          print('FCM token sent to server successfully: ${response['message']}');
        } else {
          print('Failed to send FCM token to server: ${response['message']}');
        }
      } catch (e) {
        print('Error sending FCM token to server: $e');
      }
    }
  }

  // Setup notification channels
  Future<void> setupNotificationChannels() async {
    // For regular notifications
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel', // id
      'Default Notifications', // title
      description: 'Used for default notifications', // description
      importance: Importance.high,
    );

    // For foreground service
    const AndroidNotificationChannel foregroundChannel = AndroidNotificationChannel(
      'foreground_channel', // id
      'Foreground Service', // title
      description: 'Used for foreground service notifications', // description
      importance: Importance.low,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(foregroundChannel);
  }

  // Handle notification navigation
  void handleNotificationNavigation(Map<String, dynamic> data, BuildContext? context) {
    // Example: if notification is about a new training
    if (data.containsKey('type')) {
      switch(data['type']) {
        case 'training':
          if (context != null) {
            Navigator.of(context).pushNamed('/trainings');
          }
          break;
        case 'profile':
          if (context != null) {
            Navigator.of(context).pushNamed('/profile');
          }
          break;
      // Add more types as needed
      }
    }
  }

  // Setup Firebase Messaging
  Future<void> setupFirebaseMessaging() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission on iOS
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup notification channels
    await setupNotificationChannels();

    // Get FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    print('🔥 FCM Token: $token');
    await saveAndSendTokenToServer(token);

    // Listen for token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await saveAndSendTokenToServer(newToken);
    });

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Add iOS-specific notification settings
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Update to include iOS settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap when app is in foreground
        if (details.payload != null) {
          try {
            final data = jsonDecode(details.payload!);
            final context = GlobalKey<NavigatorState>().currentContext;
            handleNotificationNavigation(data, context);
          } catch (e) {
            print('Error handling notification response: $e');
          }
        }
      },
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Check for notification from Firebase
      if (notification != null) {
        // Show notification with iOS support
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default Notifications',
              importance: Importance.high,
              priority: Priority.high,
              channelShowBadge: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // Handle notification when app is terminated and opened from notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        final context = GlobalKey<NavigatorState>().currentContext;
        handleNotificationNavigation(message.data, context);
      }
    });

    // Handle notification when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final context = GlobalKey<NavigatorState>().currentContext;
      handleNotificationNavigation(message.data, context);
    });
  }

  // Add this method to FirebaseMessagingService
  Future<void> sendTokenToServerAfterLogin() async {
    final token = await SharedPrefsService.getFcmToken();
    await saveAndSendTokenToServer(token);
  }

  // Future<void> initializeWithoutFirebase() async {
  //   await setupFirebaseMessaging();
  // }
}