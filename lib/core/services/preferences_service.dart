import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyUserSession = 'user_session';
  static const String _keyUserEmail = 'user_email';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyRememberedEmail = 'remembered_email';

  // SharedPreferences instance
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Check if the app is being launched for the first time
  static bool isFirstLaunch() {
    return _prefs?.getBool(_keyFirstLaunch) ?? true;
  }

  // Set first launch to false after the get started screen is shown
  static Future<void> setFirstLaunchComplete() async {
    await _prefs?.setBool(_keyFirstLaunch, false);
  }

  // Save user session
  static Future<void> saveUserSession(String session) async {
    await _prefs?.setString(_keyUserSession, session);
  }

  // Get user session
  static String? getUserSession() {
    return _prefs?.getString(_keyUserSession);
  }

  // Save user email
  static Future<void> saveUserEmail(String email) async {
    await _prefs?.setString(_keyUserEmail, email);
  }

  // Get user email
  static String? getUserEmail() {
    return _prefs?.getString(_keyUserEmail);
  }

  // Clear user session (for logout)
  static Future<void> clearUserSession() async {
    await _prefs?.remove(_keyUserSession);
    await _prefs?.remove(_keyUserEmail);
  }

  // Remember Me functionality
  static Future<void> setRememberMe(bool rememberMe) async {
    await _prefs?.setBool(_keyRememberMe, rememberMe);
  }

  static bool getRememberMe() {
    return _prefs?.getBool(_keyRememberMe) ?? false;
  }

  static Future<void> saveRememberedEmail(String email) async {
    await _prefs?.setString(_keyRememberedEmail, email);
  }

  static String? getRememberedEmail() {
    return _prefs?.getString(_keyRememberedEmail);
  }

  static Future<void> clearRememberedEmail() async {
    await _prefs?.remove(_keyRememberedEmail);
    await _prefs?.setBool(_keyRememberMe, false);
  }
}
