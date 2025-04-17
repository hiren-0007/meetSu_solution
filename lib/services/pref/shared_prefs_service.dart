import 'package:meetsu_solutions/model/auth/login/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPrefsService? _instance;
  static late SharedPreferences _prefs;
  static bool _initialized = false;

  // Keys for storing data
  static const String _accessTokenKey = 'access_token';
  static const String _isTempLoginKey = 'is_temp_login';
  static const String _usernameKey = 'username';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _userIdKey = 'user_id';

  // Private constructor
  SharedPrefsService._();

  /// Initializes the shared preferences service.
  static Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  /// Gets the singleton instance of SharedPrefsService
  static SharedPrefsService get instance {
    if (!_initialized) {
      throw StateError('SharedPrefsService not initialized. Call init() first.');
    }
    _instance ??= SharedPrefsService._();
    return _instance!;
  }

  /// Static methods for direct access without using the instance
  static Future<bool> setString(String key, String value) async {
    if (!_initialized) {
      throw StateError('SharedPrefsService not initialized. Call init() first.');
    }
    return await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    if (!_initialized) {
      throw StateError('SharedPrefsService not initialized. Call init() first.');
    }
    return _prefs.getString(key);
  }

  /// Saves the FCM token for push notifications
  static Future<bool> saveFcmToken(String token) async {
    if (!_initialized) {
      throw StateError('SharedPrefsService not initialized. Call init() first.');
    }
    return await _prefs.setString(_fcmTokenKey, token);
  }

  /// Gets the FCM token
  static String? getFcmToken() {
    if (!_initialized) {
      throw StateError('SharedPrefsService not initialized. Call init() first.');
    }
    return _prefs.getString(_fcmTokenKey);
  }

  /// Saves the user ID
  static Future<bool> saveUserId(String userId) async {
    if (!_initialized) {
      throw StateError('SharedPrefsService not initialized. Call init() first.');
    }
    return await _prefs.setString(_userIdKey, userId);
  }

  /// Gets the user ID
  static String? getUserId() {
    if (!_initialized) {
      throw StateError('SharedPrefsService not initialized. Call init() first.');
    }
    return _prefs.getString(_userIdKey);
  }

  /// Saves the access token to shared preferences
  Future<bool> saveAccessToken(String token) async {
    return await _prefs.setString(_accessTokenKey, token);
  }

  /// Gets the access token from shared preferences
  String? getAccessToken() {
    return _prefs.getString(_accessTokenKey);
  }

  /// Checks if an access token exists
  bool hasAccessToken() {
    return _prefs.containsKey(_accessTokenKey) &&
        (_prefs.getString(_accessTokenKey)?.isNotEmpty ?? false);
  }

  /// Removes the access token
  Future<bool> removeAccessToken() async {
    return await _prefs.remove(_accessTokenKey);
  }

  /// Saves the temporary login status
  Future<bool> saveTempLoginStatus(int isTempLogin) async {
    return await _prefs.setInt(_isTempLoginKey, isTempLogin);
  }

  /// Gets the temporary login status
  int? getTempLoginStatus() {
    return _prefs.getInt(_isTempLoginKey);
  }

  /// Saves the login response model data
  Future<bool> saveLoginResponse(LoginResponseModel response) async {
    bool result = true;

    if (response.accessToken != null) {
      result = await saveAccessToken(response.accessToken!) && result;
    }

    if (response.isTempLogin != null) {
      result = await saveTempLoginStatus(response.isTempLogin!) && result;
    }

    return result;
  }

  // Clear all data
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  Future<bool> saveUsername(String username) async {
    return await _prefs.setString(_usernameKey, username);
  }

  String getUsername() {
    return _prefs.getString(_usernameKey) ?? 'User';
  }
}