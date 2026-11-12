import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/secure_storage.dart';
import '../domain/education_models.dart';

/// Penyimpanan data Jejak Studi.
///
/// Backend belum punya endpoint data pendidikan, jadi sementara disimpan
/// lokal di SharedPreferences, dipisah per user (`user_id` dari JWT) supaya
/// akun lain di device yang sama tidak melihat data ini. Ganti isi class
/// ini ke API begitu endpoint backend tersedia.
class EducationRepository {
  static const _keyPrefix = 'jejak_studi_v1_';

  Future<EducationData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(await _key());
    if (raw == null) return const EducationData();
    try {
      return EducationData.fromJson(jsonDecode(raw));
    } catch (_) {
      return const EducationData();
    }
  }

  Future<void> save(EducationData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(await _key(), jsonEncode(data.toJson()));
  }

  Future<String> _key() async {
    final token = await AppSecureStorage.readToken();
    return '$_keyPrefix${userIdFromToken(token) ?? 'anon'}';
  }
}

/// Ambil claim `user_id` dari payload JWT backend (tanpa verifikasi —
/// cuma dipakai sebagai kunci penyimpanan lokal).
String? userIdFromToken(String? token) {
  if (token == null) return null;
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final map = jsonDecode(payload);
    return map is Map ? map['user_id'] as String? : null;
  } catch (_) {
    return null;
  }
}
