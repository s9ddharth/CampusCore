import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();

  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    final preferences = _preferences;

    if (preferences == null) {
      throw StateError(
        'LocalStorage has not been initialized. '
        'Call LocalStorage.init() before accessing storage.',
      );
    }

    return preferences;
  }

  // ---------------------------------------------------------------------------
  // String
  // ---------------------------------------------------------------------------

  static Future<bool> setString(
    String key,
    String value,
  ) async {
    return _instance.setString(key, value);
  }

  static String? getString(String key) {
    return _instance.getString(key);
  }

  // ---------------------------------------------------------------------------
  // Integer
  // ---------------------------------------------------------------------------

  static Future<bool> setInt(
    String key,
    int value,
  ) async {
    return _instance.setInt(key, value);
  }

  static int? getInt(String key) {
    return _instance.getInt(key);
  }

  // ---------------------------------------------------------------------------
  // Double
  // ---------------------------------------------------------------------------

  static Future<bool> setDouble(
    String key,
    double value,
  ) async {
    return _instance.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _instance.getDouble(key);
  }

  // ---------------------------------------------------------------------------
  // Boolean
  // ---------------------------------------------------------------------------

  static Future<bool> setBool(
    String key,
    bool value,
  ) async {
    return _instance.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _instance.getBool(key);
  }

  // ---------------------------------------------------------------------------
  // String List
  // ---------------------------------------------------------------------------

  static Future<bool> setStringList(
    String key,
    List<String> value,
  ) async {
    return _instance.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _instance.getStringList(key);
  }

  // ---------------------------------------------------------------------------
  // JSON Object
  // ---------------------------------------------------------------------------

  static Future<bool> setJson(
    String key,
    dynamic value,
  ) async {
    try {
      final encoded = jsonEncode(value);
      return await _instance.setString(key, encoded);
    } catch (_) {
      return false;
    }
  }

  static dynamic getJson(String key) {
    final value = _instance.getString(key);

    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(value);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Generic
  // ---------------------------------------------------------------------------

  static bool contains(String key) {
    return _instance.containsKey(key);
  }

  static Future<bool> remove(String key) async {
    return _instance.remove(key);
  }

  static Future<bool> clear() async {
    return _instance.clear();
  }

  // ---------------------------------------------------------------------------
  // Authentication helpers
  // ---------------------------------------------------------------------------

  static Future<bool> saveUserRole(String role) async {
    return setString('user_role', role);
  }

  static String? getUserRole() {
    return getString('user_role');
  }

  static Future<bool> saveUserId(int userId) async {
    return setInt('user_id', userId);
  }

  static int? getUserId() {
    return getInt('user_id');
  }

  static Future<bool> saveUserData(
    Map<String, dynamic> userData,
  ) async {
    return setJson('current_user', userData);
  }

  static Map<String, dynamic>? getUserData() {
    final data = getJson('current_user');

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  static Future<void> clearAuthenticationData() async {
    await remove('user_role');
    await remove('user_id');
    await remove('current_user');
  }

  // ---------------------------------------------------------------------------
  // Academic selection helpers
  // ---------------------------------------------------------------------------

  static Future<bool> saveSelectedSemester(
    int semester,
  ) async {
    return setInt('last_selected_semester', semester);
  }

  static int? getSelectedSemester() {
    return getInt('last_selected_semester');
  }

  static Future<bool> saveSelectedAcademicYear(
    String academicYear,
  ) async {
    return setString(
      'last_selected_academic_year',
      academicYear,
    );
  }

  static String? getSelectedAcademicYear() {
    return getString('last_selected_academic_year');
  }

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------

  static Future<bool> setOnboardingCompleted(
    bool completed,
  ) async {
    return setBool('onboarding_completed', completed);
  }

  static bool isOnboardingCompleted() {
    return getBool('onboarding_completed') ?? false;
  }

  // ---------------------------------------------------------------------------
  // Debug / maintenance
  // ---------------------------------------------------------------------------

  static Set<String> getKeys() {
    return _instance.getKeys();
  }
}