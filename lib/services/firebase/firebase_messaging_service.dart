import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';

import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';

import 'package:meetsu_solutions/main.dart' show navigatorKey;

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('💥 Background Message: ${message.messageId}');
  }

  Future<void> initialize() async {
    try {
      // Firebase core should already be initialized in main.dart
      print('Setting up Firebase Messaging');

      // Request permissions for notifications based on platform
      await requestNotificationPermissions();

      await setupFirebaseMessaging();
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  Future<void> requestNotificationPermissions() async {
    // For iOS notification permissions
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: false,
        announcement: false,
      );
      print('iOS notification permissions requested');
    }
    // For Android 13+ (API level 33+)
    else if (Platform.isAndroid) {
      // Using permission_handler for Android
      PermissionStatus status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
        print('Android notification permissions requested');
      }
    }
  }

  /// Check if FCM token should be sent based on login type
  bool _shouldSendFcmToken() {
    final loginType = SharedPrefsService.instance.getLoginType();

    // Only send FCM token for applicant users, not for client users
    if (loginType == null || loginType.isEmpty) {
      print('Login type not found, skipping FCM token');
      return false;
    }

    final shouldSend = loginType.toLowerCase() == 'applicant';
    print('Login type: $loginType, Should send FCM token: $shouldSend');

    return shouldSend;
  }

  Future<void> saveAndSendTokenToServer(String? token) async {
    if (token != null) {
      await SharedPrefsService.saveFcmToken(token);

      if (!_shouldSendFcmToken()) {
        print('Skipping FCM token API call - user is not an applicant');
        return;
      }

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

  Future<void> setupNotificationChannels() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'default_channel', // id
        'Default Notifications', // title
        description: 'Used for default notifications', // description
        importance: Importance.high,
      );

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
  }

  void handleNotificationNavigation(Map<String, dynamic> data, BuildContext? context) {
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
      }
    }
  }

  Future<void> setupFirebaseMessaging() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await setupNotificationChannels();

    if (Platform.isIOS) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    String? token = await FirebaseMessaging.instance.getToken();
    print('🔥 FCM Token: $token');
    await saveAndSendTokenToServer(token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await saveAndSendTokenToServer(newToken);
    });

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null) {
          try {
            final data = jsonDecode(details.payload!);
            handleNotificationNavigation(data, navigatorKey.currentContext);
          } catch (e) {
            print('Error handling notification response: $e');
          }
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
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

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        handleNotificationNavigation(message.data, navigatorKey.currentContext);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationNavigation(message.data, navigatorKey.currentContext);
    });
  }

  Future<void> sendTokenToServerAfterLogin() async {
    final token = await SharedPrefsService.getFcmToken();
    await saveAndSendTokenToServer(token);
  }
}