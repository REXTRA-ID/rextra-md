import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import 'models/riasec_models.dart';
import 'models/ikigai_models.dart';
import 'riasec_mock.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}

class KenaliDiriRepository {
  final Dio _dio = ApiClient.dio;

  // Saat backend siap, app sebaiknya tidak menutupi kegagalan backend dengan mock.
  static const bool allowMockFallback = false;

  static String resolveAssessmentPath(String endpoint) {
    final normalized = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    if (normalized.startsWith('assessment/')) {
      return '/$normalized';
    }
    if (normalized.startsWith('assesment/')) {
      return '/${normalized.replaceFirst('assesment/', 'assessment/')}';
    }
    return '/assessment/$normalized';
  }

  static String resolveLegacyAssessmentPath(String endpoint) {
    final normalized = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    if (normalized.startsWith('assesment/')) {
      return '/$normalized';
    }
    if (normalized.startsWith('assessment/')) {
      return '/${normalized.replaceFirst('assessment/', 'assesment/')}';
    }
    return '/assesment/$normalized';
  }

  static bool isSuccessfulAssessmentResponse(dynamic data) {
    if (data is! Map) return false;

    if (data['success'] is bool) {
      return data['success'] == true;
    }
    if (data['valid'] is bool) {
      return data['valid'] == true;
    }
    if (data['status'] is String) {
      return data['status'].toString().toLowerCase() == 'success';
    }
    return data['data'] != null;
  }

  Future<Response<dynamic>> _requestAssessment(
    String endpoint, {
    required String method,
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final paths = [
      resolveAssessmentPath(endpoint),
      resolveLegacyAssessmentPath(endpoint),
    ].toSet().toList();

    DioException? lastError;

    for (int i = 0; i < paths.length; i++) {
      try {
        final res = await _dio.request(
          paths[i],
          data: data,
          queryParameters: queryParameters,
          options: Options(method: method),
        );

        if (res.statusCode != null && res.statusCode! >= 400) {
          if (i == 0 && (res.statusCode == 404 || res.statusCode == 405)) {
            continue;
          }
          return res;
        }

        return res;
      } on DioException catch (e) {
        lastError = e;
        if (e.response?.statusCode == 404 && i == 0) {
          continue;
        }
        rethrow;
      }
    }

    if (lastError != null) {
      throw lastError!;
    }

    throw DioException(
      requestOptions: RequestOptions(path: paths.first, method: method),
      error: 'Assessment endpoint unavailable',
    );
  }

  // --------------------------------------------------------------------------
  // VALIDASI
  // --------------------------------------------------------------------------
  Future<bool> validateHash(String code) async {
    // CHEAT CODE BYPASS
    if (code == 'rextra123') return true;

    final res = await _requestAssessment(
      '/validate_hash',
      method: 'POST',
      data: {'hash': code},
    );

    if (res.data is Map) {
      final m = res.data as Map;
      return m['success'] == true || m['valid'] == true;
    }
    return false;
  }

  // --------------------------------------------------------------------------
  // RIASEC
  // --------------------------------------------------------------------------
  Future<List<RiasecQuestion>> getRiasecQuestions() async {
    try {
      final res = await _requestAssessment(
        '/test/riasec/question',
        method: 'GET',
      );

      final body = res.data;
      if (body is Map && body['data'] is List) {
        final list = body['data'] as List;
        if (list.isNotEmpty) {
          final questions = list.map((e) => RiasecQuestion.fromJson(Map<String, dynamic>.from(e as Map))).toList();
          const order = {'R': 0, 'I': 1, 'A': 2, 'S': 3, 'E': 4, 'C': 5};
          int numOf(String id) {
            final m = RegExp(r'(\d+)').firstMatch(id);
            return int.tryParse(m?.group(1) ?? '0') ?? 0;
          }

          questions.sort((a, b) {
            final pa = order[a.id[0].toUpperCase()] ?? 99;
            final pb = order[b.id[0].toUpperCase()] ?? 99;
            if (pa != pb) return pa.compareTo(pb);
            return numOf(a.id).compareTo(numOf(b.id));
          });

          return questions;
        }
      }
    } catch (_) {
      if (!allowMockFallback) {
        rethrow;
      }
    }

    if (!allowMockFallback) {
      throw Exception('Pertanyaan RIASEC tidak tersedia dari backend.');
    }

    final List list = mockRiasecQuestions;
    final questions = list.map((e) => RiasecQuestion.fromJson(e)).toList();

    const order = {'R': 0, 'I': 1, 'A': 2, 'S': 3, 'E': 4, 'C': 5};
    int numOf(String id) {
      final m = RegExp(r'(\d+)').firstMatch(id);
      return int.tryParse(m?.group(1) ?? '0') ?? 0;
    }

    questions.sort((a, b) {
      final pa = order[a.id[0].toUpperCase()] ?? 99;
      final pb = order[b.id[0].toUpperCase()] ?? 99;
      if (pa != pb) return pa.compareTo(pb);
      return numOf(a.id).compareTo(numOf(b.id));
    });

    return questions;
  }

  Future<void> submitRiasecList(List<int> answers) async {
    try {
      if (kDebugMode) {
        print('SUBMIT RIASEC PAYLOAD (${answers.length}) => $answers');
      }

      final res = await _requestAssessment(
        '/test/riasec/submit',
        method: 'POST',
        data: {'answers': answers},
      );

      if (!isSuccessfulAssessmentResponse(res.data)) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          error: res.data ?? 'Submit RIASEC gagal',
        );
      }
    } on DioException {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _getRiasecRawResult() async {
    final res = await _requestAssessment(
      '/test/riasec/result',
      method: 'GET',
    );

    dynamic data = res.data;
    if (data is Map) {
      data = data['data'];
    }

    if (kDebugMode) debugPrint('RIASEC RESULT RAW => ${res.data}');

    if (data is List && data.isNotEmpty) {
      final last = data.last;
      if (last is Map) return Map<String, dynamic>.from(last);
    }
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<bool> waitRiasecProfileReady({
    int maxTry = 15,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (int i = 1; i <= maxTry; i++) {
      try {
        final raw = await _getRiasecRawResult();
        final code = raw?['profile']?.toString() ?? raw?['code']?.toString() ?? '';
        if (kDebugMode) {
          debugPrint('RIASEC RESULT POLLING ($i/$maxTry) => $code');
        }
        if (code.length >= 3) return true;
      } catch (_) {}
      await Future.delayed(delay);
    }
    return false;
  }

  Future<RiasecResult> getRiasecResult() async {
    final res = await _requestAssessment(
      '/test/riasec/result',
      method: 'GET',
    );

    final payload = res.data;
    if (payload is Map) {
      final data = payload['data'];
      if (data is List && data.isNotEmpty) {
        final latest = data.last;
        if (latest is Map) return RiasecResult.fromJson(Map<String, dynamic>.from(latest));
      }
      if (data is Map) {
        return RiasecResult.fromJson(Map<String, dynamic>.from(data));
      }
      if (payload['code'] != null || payload['summary'] != null || payload['letters'] != null) {
        return RiasecResult.fromJson(Map<String, dynamic>.from(payload));
      }
    }

    throw Exception('Gagal memuat hasil RIASEC');
  }

  // --------------------------------------------------------------------------
  // IKIGAI
  // --------------------------------------------------------------------------
  /// Bruno: data.ikigai_questions = [{dimension, instruction, options}, ...]
  /// Kita generate 4 pertanyaan (id 1..4)
  Future<List<IkigaiQuestion>> getIkigaiQuestions() async {
    try {
      debugPrint('  MULAI GET IKIGAI QUESTIONS');
      final res = await _requestAssessment(
        '/test/ikigai/question',
        method: 'GET',
      );

      final raw = res.data is Map ? (res.data as Map)['data'] ?? res.data : res.data;
      debugPrint('  RESP KEYS: ${res.data is Map ? (res.data as Map).keys : res.data.runtimeType}');
      debugPrint('  DATA TYPE: ${raw.runtimeType}');
      try {
        final preview = jsonEncode(raw);
        debugPrint('  DATA PREVIEW: ${preview.substring(0, math.min(1200, preview.length))}');
      } catch (_) {}

      final out = <IkigaiQuestion>[];

      if (raw is Map && raw['ikigai_questions'] is List) {
        final list = raw['ikigai_questions'] as List;
        for (int i = 0; i < list.length; i++) {
          final g = list[i];
          if (g is Map && g['instruction'] != null && g['options'] is List) {
            out.add(
              IkigaiQuestion(
                id: i + 1,
                text: (g['instruction'] ?? '').toString(),
                options: IkigaiQuestion.parseOptions(g['options']),
                enableReason: true,
              ),
            );
          }
        }
        debugPrint('  IKIGAI parsed -> ${out.length} questions');
        return out;
      }

      return [];
    } on DioException catch (e) {
      debugPrint('GET IKIGAI QUESTIONS ERROR => ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  /// IKIGAI submit versi Bruno:
  /// {
  ///   "answers": { "1": 4, "2": 5, "3": 3, "4": 4 }
  /// }
  Future<void> submitIkigaiSimple(Map<int, int> answers) async {
    try {
      final payload = answers.map((k, v) => MapEntry(k.toString(), v));
      final res = await _requestAssessment(
        '/test/ikigai/submit',
        method: 'POST',
        data: {'answers': payload},
      );
      if (!isSuccessfulAssessmentResponse(res.data)) {
        throw ApiException(_readErrorFromResponse(res.data), status: res.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(_readError(e), status: e.response?.statusCode);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// (Opsional) versi lama – jika masih dipakai UI lamamu.
  Future<void> submitIkigai(
      Map<int, Set<int>> selections,
      Map<int, String> reasons,
      ) async {
    try {
      final payload = selections.entries
          .map((e) => {
        'id': e.key,
        'options': e.value.toList(),
        'reason': reasons[e.key] ?? '',
      })
          .toList();
      final res = await _requestAssessment(
        '/test/ikigai/submit',
        method: 'POST',
        data: {'answers': payload},
      );
      if (!isSuccessfulAssessmentResponse(res.data)) {
        throw ApiException(_readErrorFromResponse(res.data), status: res.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(_readError(e), status: e.response?.statusCode);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Ambil hasil IKIGAI – normalisasi dari struktur Bruno
  Future<IkigaiResult> getIkigaiResult() async {
    try {
      final res = await _requestAssessment(
        '/test/ikigai/result',
        method: 'GET',
      );
      debugPrint('IKIGAI RESULT RAW => ${res.data}');

      dynamic data = res.data is Map ? (res.data as Map)['data'] : null;
      if (data is List && data.isNotEmpty) data = data.first;
      if (data is! Map) {
        if (res.data is Map) data = (res.data as Map)['data'] ?? res.data;
      }
      data = (data ?? {}) as Map;

      // kode RIASEC
      final code = (data['riasec_code'] ?? data['profile'] ?? '').toString();

      // summary opsional
      final summary = (data['riasec_summary'] ?? data['summary'] ?? '').toString();

      // penjelasan huruf – riasec_explanations
      Map<String, String> letters = {};
      if (data['riasec_explanations'] is Map) {
        letters = (data['riasec_explanations'] as Map)
            .map((k, v) => MapEntry(k.toString(), v.toString()));
      } else if (data['letters'] is Map) {
        letters = (data['letters'] as Map)
            .map((k, v) => MapEntry(k.toString(), v.toString()));
      }

      // rekomendasi dari "results"
      final recs = <IkigaiRecommendation>[];
      final results = data['results'];
      if (results is Map) {
        final top2 = (results['top_2'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
            const [];
        final analysis = (results['analysis'] as List?) ?? const [];

        // peta: nama -> match
        final Map<String, num> matchByName = {};
        for (final a in analysis) {
          final m = a as Map;
          final name =
          (m['profession'] ?? m['profesi'] ?? m['title'] ?? '').toString();
          final match = (m['match_percentage'] ?? m['match'] ?? 0) as num;
          if (name.isNotEmpty) matchByName[name] = match;
        }

        if (top2.isNotEmpty) {
          recs.add(IkigaiRecommendation(
            title: top2[0],
            priority: 'pertama',
            match: (matchByName[top2[0]] ?? 0).round(),
          ));
        }
        if (top2.length > 1) {
          recs.add(IkigaiRecommendation(
            title: top2[1],
            priority: 'kedua',
            match: (matchByName[top2[1]] ?? 0).round(),
          ));
        }

        // fallback: ambil dua tertinggi dari analysis
        if (recs.isEmpty && analysis.isNotEmpty) {
          final sorted = List<Map>.from(analysis);
          sorted.sort((a, b) => ((b['match_percentage'] ?? 0) as num)
              .compareTo((a['match_percentage'] ?? 0) as num));
          for (var i = 0; i < sorted.length && i < 2; i++) {
            recs.add(IkigaiRecommendation(
              title: (sorted[i]['profession'] ?? sorted[i]['profesi'] ?? '')
                  .toString(),
              priority: i == 0 ? 'pertama' : 'kedua',
              match: ((sorted[i]['match_percentage'] ?? 0) as num).round(),
            ));
          }
        }
      }

      return IkigaiResult(
        recommendations: recs,
        riasecCode: code,
        riasecSummary: summary,
        letters: letters,
      );
    } on DioException catch (e) {
      debugPrint('GET IKIGAI RESULT ERROR => ${e.response?.data ?? e.message}');
      throw ApiException(_readError(e), status: e.response?.statusCode);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Poll IKIGAI (backend biasa butuh waktu)
  Future<IkigaiResult> pollIkigaiResult({
    int retries = 6,
    Duration delay = const Duration(seconds: 2),
  }) async {
    ApiException? lastErr;
    for (var i = 1; i <= retries; i++) {
      try {
        debugPrint('POLL IKIGAI RESULT ($i/$retries)');
        final r = await getIkigaiResult();
        if (r.recommendations.isNotEmpty || r.riasecCode.isNotEmpty) {
          return r;
        }
      } on ApiException catch (e) {
        lastErr = e;
      }
      await Future.delayed(delay);
    }
    throw lastErr ?? ApiException('Hasil IKIGAI belum siap. Coba lagi beberapa saat.');
  }

  // --------------------------------------------------------------------------
  // Utils
  // --------------------------------------------------------------------------
  String _readError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }
    return e.message ?? 'Terjadi kesalahan jaringan';
  }

  String _readErrorFromResponse(dynamic data) {
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
      if (data['detail'] != null) return data['detail'].toString();
    }
    return 'Assessment request gagal';
  }
}
