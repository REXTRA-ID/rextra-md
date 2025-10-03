import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  static const _tokenKey = 'auth_token';
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  static Future<String?> readToken() => _storage.read(key: _tokenKey);
  static Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}
