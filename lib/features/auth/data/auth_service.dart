import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  Future<String> register({
    required String fullname,
    required String email,
    required String password,
    required String phone, // <- wajib
  }) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'fullname': fullname,
        'email': email,
        'password': password,
        'phone_number': phone, // <- sesuai Bruno
      });
      final token = _extractToken(res.data);
      if (token != null) await AppSecureStorage.saveToken(token);
      return 'ok';
    } on DioException catch (e) {
      // ambil pesan dari server bila ada
      final data = e.response?.data;
      String msg = 'Registrasi gagal';
      if (data is Map && data['message'] is String) msg = data['message'];
      if (data is Map && data['error'] is String) msg = data['error'];
      if (data is String) msg = data;
      throw Exception(msg);
    }
  }

  Future<void> login({required String email, required String password}) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final token = _extractToken(res.data);
    if (token == null) {
      throw Exception('Token tidak ditemukan pada response');
    }
    await AppSecureStorage.saveToken(token);
  }

  // Placeholder – implement SSO Google nanti saat backend & SDK siap.
  Future<void> loginWithGoogle({required String idToken}) async {
    await _dio.post('/auth/google', data: {'id_token': idToken});
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/auth/me');
    return (res.data is Map<String, dynamic>) ? res.data as Map<String, dynamic> : {'data': res.data};
  }

  Future<void> logout() async {
    try {
      await _dio.delete('/auth/logout');
    } finally {
      await AppSecureStorage.deleteToken();
    }
  }

  /// Verifikasi dari link email: /auth/verify?token=...
  Future<String> verifyEmail({required String token}) async {
    final res = await _dio.get('/auth/verify', queryParameters: {'token': token});
    return res.data.toString();
  }

  String? _extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      // fleksibel: coba beberapa kemungkinan lokasi token
      if (data['token'] is String) return data['token'] as String;
      if (data['access_token'] is String) return data['access_token'] as String;
      if (data['data'] is Map && (data['data']['token'] is String)) return data['data']['token'] as String;
    }
    return null;
  }
}
