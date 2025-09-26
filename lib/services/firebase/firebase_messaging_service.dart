/*
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
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;

  FirebaseMessagingService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('💥 Background Message: ${message.messageId}');
  }

  Future<void> initialize() async {
    try {
      await requestNotificationPermissions();

      await setupFirebaseMessaging();
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  Future<void> requestNotificationPermissions() async {
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
    } else if (Platform.isAndroid) {
      PermissionStatus status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
        print('🤖 Android notification permissions requested');
      }
      print('🤖 Android notification status: $status');
    }
  }

  bool _shouldSendFcmToken() {
    final loginType = SharedPrefsService.instance.getLoginType();

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

        final deviceType = Platform.isAndroid
            ? '1'
            : Platform.isIOS
                ? '2'
                : '3';

        final tokenData = {'token': token, 'device_type': deviceType};

        final response = await apiService.fcmToken(tokenData);

        if (response['success'] == true) {
          print(
              '✅ FCM token sent to server successfully: ${response['message']}');
        } else {
          print('❌ Failed to send FCM token to server: ${response['message']}');
        }
      } catch (e) {
        print('❌ Error sending FCM token to server: $e');
      }
    } else {
      print('❌ FCM Token is null!');
    }
  }

  Future<void> setupNotificationChannels() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'default_channel',
        'Default Notifications',
        description: 'Used for default notifications',
        importance: Importance.high,
      );

      const AndroidNotificationChannel foregroundChannel =
          AndroidNotificationChannel(
        'foreground_channel',
        'Foreground Service',
        description: 'Used for foreground service notifications',
        importance: Importance.low,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(foregroundChannel);
    }
  }

  void handleNotificationNavigation(Map<String, dynamic> data, BuildContext? context) {
    debugPrint('notification is_quiz: ${data['is_quiz']}');

    if (context == null) return;

    final isQuiz = data['is_quiz']?.toString() ?? '';

    if (isQuiz == '1') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              "Quiz",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text('Check Your Quiz Option In Dashboard Screen'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      debugPrint('handle clock in');
    }
  }


  Future<void> setupFirebaseMessaging() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await setupNotificationChannels();

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    String? token = await FirebaseMessaging.instance.getToken();
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

    const InitializationSettings initializationSettings =
        InitializationSettings(
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
            debugPrint('notification type2 ${data['type']}');
          } catch (e) {
            print('❌ Error handling notification response: $e');
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

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        handleNotificationNavigation(message.data, navigatorKey.currentContext);
        debugPrint('notification type3 ${message.data['type']}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationNavigation(message.data, navigatorKey.currentContext);
      debugPrint('notification type4 ${message.data['type']}');
    });
  }

  Future<void> sendTokenToServerAfterLogin() async {
    final token = await SharedPrefsService.getFcmToken();
    await saveAndSendTokenToServer(token);
  }

}
*/

/*
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/main.dart' show navigatorKey;

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
  FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;

  FirebaseMessagingService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  late final ApiService _apiService;

  bool _isLoading = false;
  bool _showCheckInButton = false;
  bool _isCheckedIn = false;
  bool _isInitialized = false;
  String? _cachedToken;

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
  }

  Future<void> initialize() async {
    try {
      // Initialize API service
      _apiService = ApiService(ApiClient(headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }));

      await requestNotificationPermissions();
      await setupFirebaseMessaging();
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  Future<void> requestNotificationPermissions() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: false,
        announcement: false,
      );
      print('iOS notification permissions requested');
    } else if (Platform.isAndroid) {
      PermissionStatus status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
      print('🤖 Android notification status: $status');
    }
  }

  bool _shouldSendFcmToken() {
    final loginType = SharedPrefsService.instance.getLoginType();

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

        final deviceType = Platform.isAndroid
            ? '1'
            : Platform.isIOS
            ? '2'
            : '3';

        final tokenData = {'token': token, 'device_type': deviceType};

        final response = await apiService.fcmToken(tokenData);

        if (response['success'] == true) {
          print(
              '✅ FCM token sent to server successfully: ${response['message']}');
        } else {
          print('❌ Failed to send FCM token to server: ${response['message']}');
        }
      } catch (e) {
        print('❌ Error sending FCM token to server: $e');
      }
    } else {
      print('❌ FCM Token is null!');
    }
  }

  Future<void> setupNotificationChannels() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'default_channel',
        'Default Notifications',
        description: 'Used for default notifications',
        importance: Importance.high,
      );

      const AndroidNotificationChannel foregroundChannel =
      AndroidNotificationChannel(
        'foreground_channel',
        'Foreground Service',
        description: 'Used for foreground service notifications',
        importance: Importance.low,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(foregroundChannel);
    }
  }

  /// Initialize API client with authentication token
  Future<bool> _initializeWithToken() async {
    if (_isInitialized && _cachedToken != null) {
      return true;
    }

    try {
      final token = SharedPrefsService.instance.getAccessToken();
      if (token?.isNotEmpty == true) {
        _apiService.client.addAuthToken(token!);
        _cachedToken = token;
        _isInitialized = true;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('❌ Token initialization failed: $e');
      return false;
    }
  }

  /// Fetch check-in button status from API
  Future<void> _fetchCheckInButtonStatus() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      final hasToken = await _initializeWithToken();
      if (!hasToken) {
        _showCheckInButton = false;
        return;
      }

      final response = await _apiService.getCheckInButton();

      await _processCheckInResponse(response);

    } catch (e) {
      _showCheckInButton = false;
    } finally {
      _isLoading = false;
    }
  }

  /// Process the check-in API response
  Future<void> _processCheckInResponse(Map<String, dynamic> response) async {
    final shouldShowCheckIn = response['show_checkin'] == true;
    final isAlreadyCheckedIn = response['show_checkout'] == true;

    _showCheckInButton = shouldShowCheckIn && !isAlreadyCheckedIn;
    _isCheckedIn = isAlreadyCheckedIn;

  }

  /// Handle check-in action only
  Future<void> _handleCheckIn(BuildContext context) async {
    if (_isLoading) return;

    try {
      await _performCheckIn(context);
      await _fetchCheckInButtonStatus();
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to process request: ${e.toString()}');
    }
  }

  /// Perform check-in operation
  Future<void> _performCheckIn(BuildContext context) async {
    _isLoading = true;

    try {
      final hasToken = await _initializeWithToken();
      if (!hasToken) {
        throw Exception('Authentication required');
      }

      final position = await _getCurrentLocation();
      final checkInData = {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };

      final response = await _apiService.checkIn(checkInData);

      _updateCheckInState(response);
      _showResponseMessage(context, response, 'Clock-in completed');

    } catch (e) {
      _showErrorSnackBar(context, 'Check-in failed: ${e.toString()}');
    } finally {
      _isLoading = false;
    }
  }


  /// Get current location with permission handling
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  /// Update check-in state from API response
  void _updateCheckInState(Map<String, dynamic> response) {
    if (response.containsKey('show_checkin')) {
      _isCheckedIn = response['show_checkin'] == true;
    }
  }

  /// Show response message to user
  void _showResponseMessage(
      BuildContext context,
      Map<String, dynamic> response,
      String defaultMessage
      ) {
    String message = _extractMessage(response) ?? defaultMessage;
    Color color = response['success'] == true ? Colors.green : Colors.orange;

    _showSnackBar(context, message, color);
  }

  /// Extract message from API response
  String? _extractMessage(Map<String, dynamic> response) {
    final messages = <String>[];

    if (response['message1']?.isNotEmpty == true) {
      messages.add(response['message1']);
    }
    if (response['message2']?.isNotEmpty == true) {
      messages.add(response['message2']);
    }

    return messages.isNotEmpty ? messages.join(' ') : null;
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red);
  }

  void handleNotificationNavigation(Map<String, dynamic> data, BuildContext? context) {
    if (context == null) return;

    final isQuiz = data['is_quiz']?.toString() ?? '';

    if (isQuiz == '1') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              "Quiz",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text('Check Your Quiz Option In Dashboard Screen'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      _showClockInDialog(context);
    }
  }

  /// Show clock-in dialog with check-in button or message
  void _showClockInDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (!_isLoading && !_isInitialized) {
              _fetchCheckInButtonStatus().then((_) {
                if (context.mounted) {
                  setState(() {});
                }
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  Icon(
                    _showCheckInButton ? Icons.login : Icons.info_outline,
                    color: _showCheckInButton ? Colors.green : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showCheckInButton ? "Clock In" : "Schedule Info",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (_showCheckInButton)
                    const Text('Are you ready to clock in?')
                  else
                    const Text('You are not scheduled today'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                if (_showCheckInButton && !_isLoading)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _handleCheckIn(context);
                    },
                    child: const Text("Clock In"),
                  )
                else if (!_showCheckInButton && !_isLoading)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> setupFirebaseMessaging() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await setupNotificationChannels();

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    String? token = await FirebaseMessaging.instance.getToken();
    await saveAndSendTokenToServer(token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await saveAndSendTokenToServer(newToken);
    });

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
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
            print('❌ Error handling notification response: $e');
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

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
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
}*/

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
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;

  FirebaseMessagingService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
  }

  Future<void> initialize() async {
    try {
      await requestNotificationPermissions();
      await setupFirebaseMessaging();
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  Future<void> requestNotificationPermissions() async {
    if (Platform.isIOS) {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: false,
        announcement: false,
      );
      print(
          'iOS notification permissions requested - Status: ${settings.authorizationStatus}');
    } else if (Platform.isAndroid) {
      PermissionStatus status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
      print('Android notification status: $status');
    }
  }

  bool _shouldSendFcmToken() {
    final loginType = SharedPrefsService.instance.getLoginType();

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

        final deviceType = Platform.isAndroid
            ? '1'
            : Platform.isIOS
                ? '2'
                : '3';

        final tokenData = {'token': token, 'device_type': deviceType};

        final response = await apiService.fcmToken(tokenData);

        if (response['success'] == true) {
          print(
              'FCM token sent to server successfully: ${response['message']}');
        } else {
          print('Failed to send FCM token to server: ${response['message']}');
        }
      } catch (e) {
        print('Error sending FCM token to server: $e');
      }
    } else {
      print('FCM Token is null!');
    }
  }

  Future<void> setupNotificationChannels() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'default_channel',
        'Default Notifications',
        description: 'Used for default notifications',
        importance: Importance.high,
      );

      const AndroidNotificationChannel foregroundChannel =
          AndroidNotificationChannel(
        'foreground_channel',
        'Foreground Service',
        description: 'Used for foreground service notifications',
        importance: Importance.low,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(foregroundChannel);
    }
  }

  void handleNotificationNavigation(
      Map<String, dynamic> data, BuildContext? context) {
    print('Notification navigation triggered with data: $data');

    if (context == null || !context.mounted) {
      print('Context is null or not mounted, cannot navigate');
      return;
    }

    final isQuiz = data['is_quiz']?.toString() ?? '';
    print('Is quiz: $isQuiz');

    // Get current route name
    final currentRoute = ModalRoute.of(context)?.settings.name;
    print('Current route: $currentRoute');

    try {
      if (isQuiz == '1') {
        // Quiz notification
        if (currentRoute == '/home') {
          // Already on home, just update the tab/state
          // You can use a global key or state management to switch tabs
          _navigateToTab(context, 'Quiz');
        } else {
          // Navigate to home with Quiz argument
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => route
                .isFirst, // Keep only the first route (usually splash/main)
            arguments: {'name': 'Quiz', 'fromNotification': true},
          );
        }
      } else {
        // Clock-in notification
        if (currentRoute == '/home') {
          // Already on home, just update the tab/state
          _navigateToTab(context, 'Clock-In');
        } else {
          // Navigate to home with Clock-In argument
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => route.isFirst,
            arguments: {'name': 'Clock-In', 'fromNotification': true},
          );
        }
      }
    } catch (e) {
      print('Navigation error: $e');
      // Fallback navigation
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    }
  }

  void _navigateToTab(BuildContext context, String tabName) {
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {'name': tabName, 'fromNotification': true},
    );
  }

  Future<void> setupFirebaseMessaging() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await setupNotificationChannels();

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
    await saveAndSendTokenToServer(token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('FCM Token refreshed: $newToken');
      await saveAndSendTokenToServer(newToken);
    });

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        print('Notification tapped! Payload: ${details.payload}');

        if (details.payload != null && details.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(details.payload!);
            print('Parsed notification data: $data');

            Future.delayed(const Duration(milliseconds: 100), () {
              final context = navigatorKey.currentContext;
              if (context != null) {
                handleNotificationNavigation(data, context);
              } else {
                print('Context still null after delay');
              }
            });
          } catch (e) {
            print('Error parsing notification response: $e');
          }
        } else {
          print('Notification tapped but no payload found');
          final context = navigatorKey.currentContext;
          if (context != null) {
            handleNotificationNavigation({}, context);
          }
        }
      },
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}');

      RemoteNotification? notification = message.notification;
      final safePayload = {
        "title": notification?.title ?? "",
        "body": notification?.body ?? "",
        ...message.data,
      };

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
          payload: jsonEncode(safePayload),
        );
      }
    });

    // Handle app launch from notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('App launched from notification: ${message.notification?.title}');

        // Add delay to ensure app is fully initialized
        Future.delayed(const Duration(milliseconds: 500), () {
          final context = navigatorKey.currentContext;
          if (context != null) {
            handleNotificationNavigation(message.data, context);
          }
        });
      }
    });

    // Handle app opened from background via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          'App opened from background notification: ${message.notification?.title}');
      handleNotificationNavigation(message.data, navigatorKey.currentContext);
    });
  }

  Future<void> sendTokenToServerAfterLogin() async {
    final token = await SharedPrefsService.getFcmToken();
    await saveAndSendTokenToServer(token);
  }
}

/*import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meetsu_solutions/services/pref/shared_prefs_service.dart';
import 'package:meetsu_solutions/services/api/api_client.dart';
import 'package:meetsu_solutions/services/api/api_service.dart';
import 'package:meetsu_solutions/main.dart' show navigatorKey;

// Enums for better state management
enum MessagingState { initializing, ready, error }
enum NotificationType { quiz, clockIn, general }
enum DeviceType { android, ios, other }

// Constants
class MessagingConstants {
  static const String defaultChannelId = 'default_channel';
  static const String defaultChannelName = 'Default Notifications';
  static const String foregroundChannelId = 'foreground_channel';
  static const String foregroundChannelName = 'Foreground Service';
  static const String highPriorityChannelId = 'high_priority_channel';
  static const String highPriorityChannelName = 'High Priority Notifications';

  static const int maxRetryAttempts = 3;
  static const int tokenCacheHours = 1;
  static const int navigationDelay = 100;
  static const int appLaunchDelay = 500;
}

// Data models
class NotificationData {
  final String? title;
  final String? body;
  final NotificationType type;
  final Map<String, dynamic> additionalData;

  NotificationData({
    this.title,
    this.body,
    this.type = NotificationType.general,
    this.additionalData = const {},
  });

  factory NotificationData.fromRemoteMessage(RemoteMessage message) {
    final isQuiz = message.data['is_quiz'] == '1';
    return NotificationData(
      title: message.notification?.title,
      body: message.notification?.body,
      type: isQuiz ? NotificationType.quiz : NotificationType.clockIn,
      additionalData: message.data,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title ?? '',
    'body': body ?? '',
    'type': type.toString(),
    ...additionalData,
  };
}

// Token Management
class TokenManager {
  static String? _cachedToken;
  static DateTime? _lastTokenFetch;

  static Future<String?> getTokenWithCache() async {
    if (_isTokenCacheValid()) {
      return _cachedToken;
    }

    try {
      _cachedToken = await FirebaseMessaging.instance.getToken();
      _lastTokenFetch = DateTime.now();
      return _cachedToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  static bool _isTokenCacheValid() {
    return _cachedToken != null &&
        _lastTokenFetch != null &&
        DateTime.now().difference(_lastTokenFetch!).inHours < MessagingConstants.tokenCacheHours;
  }

  static bool isValidToken(String? token) {
    return token != null &&
           token.isNotEmpty &&
           token.length > 50 &&
           RegExp(r'^[a-zA-Z0-9_:-]+$').hasMatch(token);
  }

  static void clearCache() {
    _cachedToken = null;
    _lastTokenFetch = null;
  }
}

// Notification Handler
class NotificationHandler {
  static void handleNotificationNavigation(NotificationData data, BuildContext? context) {
    debugPrint('Notification navigation triggered: ${data.type}');

    if (context == null) {
      debugPrint('Context is null, cannot navigate');
      return;
    }

    try {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      String targetName;

      switch (data.type) {
        case NotificationType.quiz:
          targetName = 'Quiz';
          break;
        case NotificationType.clockIn:
          targetName = 'Clock-In';
          break;
        default:
          targetName = 'Home';
      }

      if (currentRoute != '/home') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
          arguments: {
            'name': targetName,
            'notificationData': data.toJson(),
          },
        );
      }
    } catch (e) {
      debugPrint('Error in notification navigation: $e');
    }
  }

  static void showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Permission'),
          content: const Text('Please enable notifications in settings to receive important updates.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}

// Main Firebase Messaging Service
class FirebaseMessagingService extends ChangeNotifier {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  // State management
  MessagingState _state = MessagingState.initializing;
  MessagingState get state => _state;

  // Services
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Streams
  final StreamController<NotificationData> _notificationController = StreamController<NotificationData>.broadcast();
  Stream<NotificationData> get notificationStream => _notificationController.stream;

  void _updateState(MessagingState newState) {
    _state = newState;
    notifyListeners();
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint('Background message: ${message.notification?.title}');
  }

  // Main initialization
  Future<void> initialize() async {
    try {
      _updateState(MessagingState.initializing);

      await _requestNotificationPermissions();
      await _setupNotificationChannels();
      await _setupFirebaseMessaging();

      _updateState(MessagingState.ready);
      debugPrint('Firebase Messaging initialized successfully');
    } catch (e) {
      _updateState(MessagingState.error);
      debugPrint('Error initializing Firebase Messaging: $e');
      rethrow;
    }
  }

  // Permission handling
  Future<void> _requestNotificationPermissions() async {
    try {
      if (Platform.isIOS) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
          criticalAlert: false,
          announcement: false,
        );

        debugPrint('iOS notification permissions: ${settings.authorizationStatus}');

        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            NotificationHandler.showPermissionDialog(context);
          }
        }
      } else if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        debugPrint('Android notification status: $status');

        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  // Notification channels setup
  Future<void> _setupNotificationChannels() async {
    if (!Platform.isAndroid) return;

    try {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Default channel
        const defaultChannel = AndroidNotificationChannel(
          MessagingConstants.defaultChannelId,
          MessagingConstants.defaultChannelName,
          description: 'Used for default notifications',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        // High priority channel
        const highPriorityChannel = AndroidNotificationChannel(
          MessagingConstants.highPriorityChannelId,
          MessagingConstants.highPriorityChannelName,
          description: 'Used for high priority notifications',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );

        // Foreground service channel
        const foregroundChannel = AndroidNotificationChannel(
          MessagingConstants.foregroundChannelId,
          MessagingConstants.foregroundChannelName,
          description: 'Used for foreground service notifications',
          importance: Importance.low,
        );

        await androidPlugin.createNotificationChannel(defaultChannel);
        await androidPlugin.createNotificationChannel(highPriorityChannel);
        await androidPlugin.createNotificationChannel(foregroundChannel);

        debugPrint('Android notification channels created');
      }
    } catch (e) {
      debugPrint('Error setting up notification channels: $e');
    }
  }

  // Token management
  bool _shouldSendFcmToken() {
    final loginType = SharedPrefsService.instance.getLoginType();

    if (loginType == null || loginType.isEmpty) {
      debugPrint('Login type not found, skipping FCM token');
      return false;
    }

    final shouldSend = loginType.toLowerCase() == 'applicant';
    debugPrint('Login type: $loginType, Should send FCM token: $shouldSend');
    return shouldSend;
  }

  DeviceType _getDeviceType() {
    if (Platform.isAndroid) return DeviceType.android;
    if (Platform.isIOS) return DeviceType.ios;
    return DeviceType.other;
  }

  Future<void> _saveAndSendTokenToServer(String? token, {int retryCount = 0}) async {
    if (!TokenManager.isValidToken(token)) {
      debugPrint('Invalid FCM token format');
      return;
    }

    try {
      // Save token locally
      await SharedPrefsService.saveFcmToken(token!);

      // Check if we should send to server
      if (!_shouldSendFcmToken()) {
        debugPrint('Skipping FCM token API call - user is not an applicant');
        return;
      }

      // Check access token
      final accessToken = SharedPrefsService.instance.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('Cannot send FCM token: No access token available');
        return;
      }

      // Send to server
      final apiClient = ApiClient();
      apiClient.addAuthToken(accessToken);
      final apiService = ApiService(apiClient);

      final deviceType = _getDeviceType();
      final deviceTypeString = deviceType == DeviceType.android ? '1' :
                              deviceType == DeviceType.ios ? '2' : '3';

      final tokenData = {
        'token': token,
        'device_type': deviceTypeString,
        'platform': Platform.operatingSystem,
        'app_version': '1.0.0', // You can get this from package_info_plus
      };

      final response = await apiService.fcmToken(tokenData);

      if (response['success'] == true) {
        debugPrint('FCM token sent successfully: ${response['message']}');
      } else {
        throw Exception('API error: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Error sending FCM token (attempt ${retryCount + 1}): $e');

      if (retryCount < MessagingConstants.maxRetryAttempts - 1) {
        final delay = Duration(seconds: pow(2, retryCount).toInt());
        await Future.delayed(delay);
        return _saveAndSendTokenToServer(token, retryCount: retryCount + 1);
      } else {
        debugPrint('Failed to send FCM token after ${MessagingConstants.maxRetryAttempts} attempts');
      }
    }
  }

  // Firebase messaging setup
  Future<void> _setupFirebaseMessaging() async {
    try {
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // iOS foreground presentation options
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Get and send initial token
      final token = await TokenManager.getTokenWithCache();
      debugPrint('FCM Token: $token');
      await _saveAndSendTokenToServer(token);

      // Listen to token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM Token refreshed: $newToken');
        TokenManager.clearCache();
        await _saveAndSendTokenToServer(newToken);
      });

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Set up message handlers
      _setupMessageHandlers();

      debugPrint('Firebase messaging setup completed');
    } catch (e) {
      debugPrint('Error setting up Firebase messaging: $e');
      rethrow;
    }
  }

  // Local notifications initialization
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Notification tap handler
  void _onNotificationTapped(NotificationResponse details) {
    debugPrint('Notification tapped! Payload: ${details.payload}');

    try {
      NotificationData notificationData;

      if (details.payload != null && details.payload!.isNotEmpty) {
        final data = jsonDecode(details.payload!);
        final isQuiz = data['is_quiz'] == '1';
        notificationData = NotificationData(
          title: data['title'],
          body: data['body'],
          type: isQuiz ? NotificationType.quiz : NotificationType.clockIn,
          additionalData: data,
        );
      } else {
        notificationData = NotificationData();
      }

      // Add to stream
      _notificationController.add(notificationData);

      // Navigate after delay
      Future.delayed(const Duration(milliseconds: MessagingConstants.navigationDelay), () {
        final context = navigatorKey.currentContext;
        if (context != null) {
          NotificationHandler.handleNotificationNavigation(notificationData, context);
        } else {
          debugPrint('Context still null after delay');
        }
      });
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  // Message handlers setup
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');

      final notificationData = NotificationData.fromRemoteMessage(message);
      _notificationController.add(notificationData);

      _showLocalNotification(message, notificationData);
    });

    // App launch from notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App launched from notification: ${message.notification?.title}');

        Future.delayed(const Duration(milliseconds: MessagingConstants.appLaunchDelay), () {
          final context = navigatorKey.currentContext;
          if (context != null) {
            final notificationData = NotificationData.fromRemoteMessage(message);
            NotificationHandler.handleNotificationNavigation(notificationData, context);
          }
        });
      }
    });

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from background: ${message.notification?.title}');

      final notificationData = NotificationData.fromRemoteMessage(message);
      final context = navigatorKey.currentContext;

      if (context != null) {
        NotificationHandler.handleNotificationNavigation(notificationData, context);
      }
    });
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message, NotificationData data) async {
    final notification = message.notification;
    if (notification == null) return;

    try {
      final channelId = data.type == NotificationType.quiz
          ? MessagingConstants.highPriorityChannelId
          : MessagingConstants.defaultChannelId;

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelId == MessagingConstants.highPriorityChannelId
                ? MessagingConstants.highPriorityChannelName
                : MessagingConstants.defaultChannelName,
            importance: data.type == NotificationType.quiz ? Importance.max : Importance.high,
            priority: data.type == NotificationType.quiz ? Priority.max : Priority.high,
            channelShowBadge: true,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1,
          ),
        ),
        payload: jsonEncode(data.toJson()),
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  // Public methods
  Future<void> sendTokenToServerAfterLogin() async {
    final token = await SharedPrefsService.getFcmToken();
    await _saveAndSendTokenToServer(token);
  }

  Future<String?> getCurrentToken() async {
    return await TokenManager.getTokenWithCache();
  }

  Future<void> refreshToken() async {
    TokenManager.clearCache();
    await FirebaseMessaging.instance.deleteToken();
    final newToken = await TokenManager.getTokenWithCache();
    await _saveAndSendTokenToServer(newToken);
  }

  // Cleanup
  @override
  void dispose() {
    _notificationController.close();
    super.dispose();
  }

  // Subscribe to topics (optional feature)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }
}*/
