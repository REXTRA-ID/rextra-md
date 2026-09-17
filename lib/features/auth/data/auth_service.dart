import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class AuthService {
  AuthService() {
    // Pasang interceptor sekali (idempotent di ApiClient)
    ApiClient.dio.interceptors.removeWhere((i) => i is _AuthAttachInterceptor);
    ApiClient.dio.interceptors.add(_AuthAttachInterceptor());
  }

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

      if ((res.statusCode ?? 0) >= 400) {
        throw Exception(_serverMessage(res.data) ?? 'Registrasi gagal (HTTP ${res.statusCode})');
      }

      final token = _extractTokenFromAny(res);
      if (token != null) {
        await AppSecureStorage.saveToken(token);
        ApiClient.attachBearer(token);
      }

      return _serverMessage(res.data) ?? 'Registrasi berhasil';
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
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
        throw Exception('Token tidak ditemukan pada response');
      }
      await AppSecureStorage.saveToken(token);
      ApiClient.attachBearer(token);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<void> loginWithGoogle({String? serverClientId}) async {
    // 1) Google Sign-In
    final google = GoogleSignIn(
      // optional: kalau kamu punya serverClientId OAUTH di Firebase
      serverClientId: serverClientId,
    );
    final googleUser = await google.signIn();
    if (googleUser == null) throw Exception('Login dibatalkan');

    final googleAuth = await googleUser.authentication;

    // 2) Firebase Auth
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    final userCred = await FirebaseAuth.instance.signInWithCredential(credential);

    // 3) Ambil Firebase ID Token
    final firebaseIdToken = await userCred.user!.getIdToken(true);

    // 4) Kirim ke backend (endpoint kamu)
    final res = await _dio.post('/auth/google', data: {
      'id_token': firebaseIdToken,
    }, options: Options(validateStatus: (s) => s != null && s < 600));

    if ((res.statusCode ?? 0) >= 400) {
      throw Exception(_serverMessage(res.data) ?? 'Login Google gagal (HTTP ${res.statusCode})');
    }

    // 5) Simpan token app
    final token = _extractTokenFromAny(res);
    if (token != null) {
      await AppSecureStorage.saveToken(token);
      ApiClient.attachBearer(token);
    } else {
      // Jika backend hanya set cookie, minimal biarkan interceptor mengirim cookie.
      // Namun untuk mobile, sebaiknya backend tetap kirim bearer.
    }
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/auth/me');
    return (res.data is Map<String, dynamic>) ? res.data as Map<String, dynamic> : {'data': res.data};
  }

  Future<void> logout() async {
    try {
      await _dio.delete('/auth/logout', options: Options(validateStatus: (s) => s != null && s < 600));
    } catch (_) {
      // noop
    } finally {
      await AppSecureStorage.deleteToken();
      ApiClient.detachBearer();
      // bersihin Firebase & Google
      try { await FirebaseAuth.instance.signOut(); } catch (_) {}
      try { await GoogleSignIn().signOut(); } catch (_) {}
    }
  }

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
  Future<void> resendVerification(String email) async {
    try {
      final res = await _dio.post(
        '/auth/send-email',
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

  Future<void> requestPasswordReset(String email) async {
    try {
      final res = await _dio.post(
        '/auth/forget',
        data: {'email': email},
        options: Options(validateStatus: (s) => s != null && s < 600),
      );
      if ((res.statusCode ?? 0) >= 400 || (res.data is Map && res.data['success'] == false)) {
        throw Exception(_serverMessage(res.data) ?? 'Gagal mengirim email reset');
      }
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<void> changePassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/change',
        queryParameters: {'token': token},
        data: {'new_password': newPassword},
        options: Options(validateStatus: (s) => s != null && s < 600),
      );
      if ((res.statusCode ?? 0) >= 400 || (res.data is Map && res.data['success'] == false)) {
        throw Exception(_serverMessage(res.data) ?? 'Gagal mengganti password');
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

/// Interceptor untuk menyuntikkan Bearer token dari storage jika belum ada.
class _AuthAttachInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Kalau header Authorization belum ada, ambil dari storage
    final existing = options.headers['Authorization'] ?? options.headers['authorization'];
    if (existing == null || (existing is String && existing.isEmpty)) {
      final token = await AppSecureStorage.readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    return handler.next(options);
  }
}
