import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class AuthService {
  final Dio _dio = ApiClient.dio;

  // ---------------- AUTH BASIC ----------------

  Future<String> register({
    required String fullname,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/register',
        data: {
          'fullname': fullname,
          'email': email,
          'password': password,
          'phone_number': phone,
        },
        options: Options(validateStatus: (s) => s != null && s < 600),
      );

      // Bila server balas error 4xx/5xx
      if ((res.statusCode ?? 0) >= 400) {
        throw Exception(_serverMessage(res.data) ?? 'Registrasi gagal (HTTP ${res.statusCode})');
      }

      // Beberapa server tidak kirim token saat register → optional
      final token = _extractTokenFromAny(res);
      if (token != null) await AppSecureStorage.saveToken(token);

      return _serverMessage(res.data) ?? 'Registrasi berhasil';
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final res = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: Options(
          followRedirects: false,
          validateStatus: (s) => s != null && s < 600,
        ),
      );

      if ((res.statusCode ?? 0) >= 400) {
        throw Exception(_serverMessage(res.data) ?? 'Login gagal (HTTP ${res.statusCode})');
      }

      final token = _extractTokenFromAny(res);
      if (token == null) {
        // Jika pakai session cookie, aktifkan CookieJar di ApiClient lalu hapus error ini.
        throw Exception('Token tidak ditemukan pada response');
      }
      await AppSecureStorage.saveToken(token);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<void> loginWithGoogle({required String idToken}) async {
    try {
      final res = await _dio.post(
        '/auth/google',
        data: {'id_token': idToken},
        options: Options(validateStatus: (s) => s != null && s < 600),
      );

      if ((res.statusCode ?? 0) >= 400) {
        throw Exception(_serverMessage(res.data) ?? 'Login Google gagal (HTTP ${res.statusCode})');
      }

      final token = _extractTokenFromAny(res);
      if (token == null) throw Exception('Token tidak ditemukan pada response');
      await AppSecureStorage.saveToken(token);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/auth/me');
    return (res.data is Map<String, dynamic>)
        ? res.data as Map<String, dynamic>
        : {'data': res.data};
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
    final res = await _dio.get(
      '/auth/verify',
      queryParameters: {'token': token},
      options: Options(validateStatus: (s) => s != null && s < 600),
    );
    if ((res.statusCode ?? 0) >= 400) {
      throw Exception(_serverMessage(res.data) ?? 'Verifikasi gagal (HTTP ${res.statusCode})');
    }
    return _serverMessage(res.data) ?? res.data.toString();
  }

  // ---------------- LUPA PASSWORD & RESEND ----------------

  /// Kirim email lupa password
  Future<void> requestPasswordReset(String email) async {
    try {
      final res = await _dio.post(
        '/auth/forget',
        data: {'email': email},
        options: Options(validateStatus: (s) => s != null && s < 600),
      );

      if ((res.statusCode ?? 0) >= 400) {
        throw Exception(_serverMessage(res.data) ?? 'Gagal mengirim email reset (HTTP ${res.statusCode})');
      }

      // Jika server mengirim {"success": false, ...} dengan 200
      if (res.data is Map && res.data['success'] == false) {
        throw Exception(_serverMessage(res.data) ?? 'Gagal mengirim email reset');
      }
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  /// Ganti password baru (token dari email)
  Future<void> changePassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/change',
        queryParameters: {'token': token},
        // ⚠️ backend minta "new_password", bukan "password"
        data: {'new_password': newPassword},
        options: Options(validateStatus: (s) => s != null && s < 600),
      );

      if ((res.statusCode ?? 0) >= 400) {
        throw Exception(_serverMessage(res.data) ?? 'Gagal mengganti password (HTTP ${res.statusCode})');
      }

      if (res.data is Map && res.data['success'] == false) {
        throw Exception(_serverMessage(res.data) ?? 'Gagal mengganti password');
      }
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  /// Kirim ulang verifikasi email
  Future<void> resendVerification(String email) async {
    try {
      final res = await _dio.post(
        '/auth/resend',
        data: {'email': email},
        options: Options(validateStatus: (s) => s != null && s < 600),
      );

      if ((res.statusCode ?? 0) >= 400) {
        throw Exception(_serverMessage(res.data) ?? 'Gagal mengirim ulang verifikasi (HTTP ${res.statusCode})');
      }

      if (res.data is Map && res.data['success'] == false) {
        throw Exception(_serverMessage(res.data) ?? 'Gagal mengirim ulang verifikasi');
      }
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  // ---------------- helpers ----------------

  String? _extractTokenFromAny(Response res) {
    final data = res.data;
    if (data is Map<String, dynamic>) {
      if (data['token'] is String) return data['token'] as String;
      if (data['access_token'] is String) return data['access_token'] as String;

      final d = data['data'];
      if (d is Map<String, dynamic>) {
        if (d['token'] is String) return d['token'] as String;
        if (d['access_token'] is String) return d['access_token'] as String;
        final auth = d['auth'];
        if (auth is Map && auth['access_token'] is String) {
          return auth['access_token'] as String;
        }
      }
    }

    final authHeader = res.headers.value('authorization') ?? res.headers.value('Authorization');
    if (authHeader != null && authHeader.toLowerCase().startsWith('bearer ')) {
      return authHeader.split(' ').last.trim();
    }

    final setCookies = res.headers['set-cookie'] ?? res.headers['Set-Cookie'];
    if (setCookies != null && setCookies.isNotEmpty) {
      final joined = setCookies.join('; ');
      final m = RegExp(r'(?:token|access_token)=([^;]+)').firstMatch(joined);
      if (m != null) return m.group(1);
    }
    return null;
  }

  String? _serverMessage(dynamic data) {
    if (data is Map) {
      if (data['message'] is String) return data['message'] as String;
      if (data['error'] is String && (data['error'] as String).isNotEmpty) return data['error'] as String;
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return null;
  }

  String _errorMessage(DioException e) {
    final msg = _serverMessage(e.response?.data);
    if (msg != null) return msg;
    if (e.type == DioExceptionType.connectionError) return 'Tidak bisa terhubung ke server';
    return 'HTTP ${e.response?.statusCode ?? ''} ${e.message}';
  }
}
