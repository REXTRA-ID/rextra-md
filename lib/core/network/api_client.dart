import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../config/env.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  ApiClient._();

  static final CookieJar _cookieJar = CookieJar(); // memory jar, cukup utk 1 sesi app
  static final Dio dio = Dio(BaseOptions(
    baseUrl: Env.baseUrl,
    // biar bisa baca body 400/500
    validateStatus: (_) => true,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // optional tapi aman:
      'User-Agent': 'rextra-app/1.0',
    },
  ))
  // urutan penting: cookie dulu, baru header Authorization
    ..interceptors.add(CookieManager(_cookieJar))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AppSecureStorage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (resp, handler) {
        handler.next(resp); // biar resp 400/500 tetap balik (validateStatus true)
      },
      onError: (e, handler) {
        handler.next(e);
      },
    ));
}