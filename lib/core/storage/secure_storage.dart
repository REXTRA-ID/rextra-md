import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSecureStorage {
  static const _tokenKey = 'auth_token';

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // pake EncryptedSharedPreferences
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_tokenKey, token);
      return;
    }
    // mobile/desktop
    await _secure.write(key: _tokenKey, value: token);
  }

  static Future<String?> readToken() async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      return sp.getString(_tokenKey);
    }
    return _secure.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_tokenKey);
      return;
    }
    await _secure.delete(key: _tokenKey);
  }
}
