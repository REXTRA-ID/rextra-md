import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../config/env.dart';
import '../storage/secure_storage.dart';

/// ApiClient global untuk koneksi backend.
/// Menangani:
/// - baseUrl & timeout
/// - CookieJar (biar session bisa nyimpen cookie login)
/// - Auto attach Bearer token dari SecureStorage
/// - Auto detach token (saat logout)
/// - Handling error 400/500 tanpa throw otomatis
class ApiClient {
  ApiClient._();

  // Cookie jar in-memory (sesi sementara)
  static final CookieJar _cookieJar = CookieJar();

  // Base Dio instance
  static final Dio dio = Dio(BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    validateStatus: (_) => true, // biar tetap masuk ke onResponse walau error 400
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'rextra-app/1.0',
    },
  ))
    ..interceptors.addAll([
      CookieManager(_cookieJar),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ambil token terbaru dari SecureStorage
          final token = await AppSecureStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (resp, handler) => handler.next(resp),
        onError: (e, handler) => handler.next(e),
      ),
    ]);

  /// Tambah header Authorization manual setelah login sukses
  static void attachBearer(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Hapus header Authorization saat logout
  static void detachBearer() {
    dio.options.headers.remove('Authorization');
  }

  /// Bersihkan cookie jika logout / ganti akun
  static Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  /// Tes koneksi (opsional)
  static Future<bool> ping() async {
    try {
      final res = await dio.get('/ping');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
