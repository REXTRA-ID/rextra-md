import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import 'models/riasec_models.dart';
import 'models/ikigai_models.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}

class KenaliDiriRepository {
  final Dio _dio = ApiClient.dio;

  // --------------------------------------------------------------------------
  // VALIDASI
  // --------------------------------------------------------------------------
  Future<bool> validateHash(String code) async {
    final res = await _dio.post('/assesment/validate_hash', data: {'hash': code});
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
    final res = await _dio.get('/assesment/test/riasec/question');
    final data = res.data['data'];
    final List list = data is List ? data : (data['riasec_questions'] ?? []);
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
      final res = await _dio.post(
        '/assesment/test/riasec/submit',
        data: {'answers': answers},
      );
      if (res.data is Map && res.data['success'] == false) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          error: res.data,
        );
      }
    } on DioException {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _getRiasecRawResult() async {
    final res = await _dio.get('/assesment/test/riasec/result');
    final data = res.data['data'];

    if (kDebugMode) debugPrint('RIASEC RESULT RAW => ${res.data}');

    if (data is List && data.isNotEmpty) {
      return Map<String, dynamic>.from(data.last as Map);
    }
    if (data is Map<String, dynamic>) return data;
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
    final res = await ApiClient.dio.get('/assesment/test/riasec/result');
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      if (list.isEmpty) throw Exception('Belum ada hasil RIASEC');

      // Ambil hasil terakhir (pastikan backend urut ASC atau DESC)
      final latest = list.last; // kalau backend urut ASC
      // final latest = list.first; // kalau backend urut DESC

      return RiasecResult.fromJson(latest);
    } else {
      throw Exception('Gagal memuat hasil RIASEC');
    }
  }

  // --------------------------------------------------------------------------
  // IKIGAI
  // --------------------------------------------------------------------------
  /// Bruno: data.ikigai_questions = [{dimension, instruction, options}, ...]
  /// Kita generate 4 pertanyaan (id 1..4)
  Future<List<IkigaiQuestion>> getIkigaiQuestions() async {
    try {
      debugPrint('  MULAI GET IKIGAI QUESTIONS');
      final res = await _dio.get('/assesment/test/ikigai/question');

      final raw = res.data['data'];
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
                id: i + 1, // 1..4
                text: (g['instruction'] ?? '').toString(),
                options: IkigaiQuestion.parseOptions(g['options']),
                enableReason: true, // biarkan true agar UI bisa isi alasan bila kosong
              ),
            );
          }
        }
        debugPrint('  IKIGAI parsed -> ${out.length} questions');
        return out;
      }

      // fallback (bentuk lain)
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
      await _dio.post('/assesment/test/ikigai/submit', data: {'answers': payload});
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
      await _dio.post('/assesment/test/ikigai/submit', data: {'answers': payload});
    } on DioException catch (e) {
      throw ApiException(_readError(e), status: e.response?.statusCode);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Ambil hasil IKIGAI – normalisasi dari struktur Bruno
  Future<IkigaiResult> getIkigaiResult() async {
    try {
      final res = await _dio.get('/assesment/test/ikigai/result');
      debugPrint('IKIGAI RESULT RAW => ${res.data}');

      dynamic data = res.data['data'];
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
}
