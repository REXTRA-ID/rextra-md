import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSecureStorage {
  static const _tokenKey = 'auth_token';
  static const _loginAtKey = 'auth_login_at';

  /// Sesi dianggap habis kalau sudah lebih dari durasi ini sejak login,
  /// terlepas dari masa berlaku JWT-nya sendiri di backend.
  static const sessionDuration = Duration(hours: 1);

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // pake EncryptedSharedPreferences
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static Future<void> saveToken(String token) async {
    final loginAt = DateTime.now().toIso8601String();
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_tokenKey, token);
      await sp.setString(_loginAtKey, loginAt);
      return;
    }
    // mobile/desktop
    await _secure.write(key: _tokenKey, value: token);
    await _secure.write(key: _loginAtKey, value: loginAt);
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
      await sp.remove(_loginAtKey);
      return;
    }
    await _secure.delete(key: _tokenKey);
    await _secure.delete(key: _loginAtKey);
  }

  /// True kalau ada token DAN belum lebih dari [sessionDuration] sejak login.
  /// Kalau sudah lewat, token otomatis dihapus supaya status "logged out"
  /// konsisten di seluruh app pada pengecekan berikutnya.
  static Future<bool> hasValidSession() async {
    final token = await readToken();
    if (token == null || token.isEmpty) return false;

    final loginAtRaw = kIsWeb
        ? (await SharedPreferences.getInstance()).getString(_loginAtKey)
        : await _secure.read(key: _loginAtKey);

    final loginAt = loginAtRaw != null ? DateTime.tryParse(loginAtRaw) : null;
    if (loginAt == null) {
      // Token lama dari sebelum fitur timeout ini ada -> anggap masih
      // valid sekali ini, supaya tidak langsung ke-logout paksa tanpa
      // pernah login ulang. Timestamp-nya diisi sekarang untuk ke depannya.
      final sp = kIsWeb ? await SharedPreferences.getInstance() : null;
      final now = DateTime.now().toIso8601String();
      if (kIsWeb) {
        await sp!.setString(_loginAtKey, now);
      } else {
        await _secure.write(key: _loginAtKey, value: now);
      }
      return true;
    }

    if (DateTime.now().difference(loginAt) > sessionDuration) {
      await deleteToken();
      return false;
    }
    return true;
  }
}
