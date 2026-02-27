import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../config/env.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  ApiClient._();

  static final CookieJar _cookieJar = CookieJar();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      validateStatus: (_) => true,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'rextra-app/1.0',
      },
    ),
  )
    ..interceptors.addAll([
      CookieManager(_cookieJar),

      /// Attach token otomatis
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AppSecureStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        onResponse: (resp, handler) {
          return handler.next(resp);
        },

        onError: (e, handler) {
          // Biar error lebih jelas
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.unknown) {
            return handler.next(
              DioException(
                requestOptions: e.requestOptions,
                error: 'Tidak dapat terhubung ke server',
              ),
            );
          }
          return handler.next(e);
        },
      ),
    ]);

  /// 🔥 BYPASS SSL SELF-SIGNED (DEBUG ONLY)
  static void enableDebugSSLBypass() {
    if (!kReleaseMode) {
      final adapter = dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };
      }
    }
  }

  static void attachBearer(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void detachBearer() {
    dio.options.headers.remove('Authorization');
  }

  static Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  static Future<bool> ping() async {
    try {
      final res = await dio.get('/ping');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}