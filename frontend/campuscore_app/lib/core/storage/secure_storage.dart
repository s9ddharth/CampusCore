import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility:
          KeychainAccessibility.first_unlock,
    ),
  );

  // ---------------------------------------------------------------------------
  // Keys
  // ---------------------------------------------------------------------------

  static const String accessTokenKey = 'access_token';

  static const String refreshTokenKey = 'refresh_token';

  // ---------------------------------------------------------------------------
  // Generic string operations
  // ---------------------------------------------------------------------------

  static Future<void> write(
    String key,
    String value,
  ) async {
    await _storage.write(
      key: key,
      value: value,
    );
  }

  static Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  static Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }

  static Future<Map<String, String>> readAll() async {
    return _storage.readAll();
  }

  // ---------------------------------------------------------------------------
  // Access token
  // ---------------------------------------------------------------------------

  static Future<void> saveAccessToken(
    String token,
  ) async {
    await write(accessTokenKey, token);
  }

  static Future<String?> getAccessToken() async {
    return read(accessTokenKey);
  }

  static Future<void> deleteAccessToken() async {
    await delete(accessTokenKey);
  }

  // ---------------------------------------------------------------------------
  // Refresh token
  // ---------------------------------------------------------------------------

  static Future<void> saveRefreshToken(
    String token,
  ) async {
    await write(refreshTokenKey, token);
  }

  static Future<String?> getRefreshToken() async {
    return read(refreshTokenKey);
  }

  static Future<void> deleteRefreshToken() async {
    await delete(refreshTokenKey);
  }

  // ---------------------------------------------------------------------------
  // Authentication helpers
  // ---------------------------------------------------------------------------

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await saveAccessToken(accessToken);

    if (refreshToken != null &&
        refreshToken.trim().isNotEmpty) {
      await saveRefreshToken(refreshToken);
    }
  }

  static Future<bool> hasAccessToken() async {
    final token = await getAccessToken();

    return token != null && token.trim().isNotEmpty;
  }

  static Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();

    return token != null && token.trim().isNotEmpty;
  }

  static Future<void> clearAuthentication() async {
    await deleteAccessToken();
    await deleteRefreshToken();
  }
}