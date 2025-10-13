import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'models/riasec_models.dart';
import 'models/ikigai_models.dart';

class KenaliDiriRepository {
  final Dio _dio = ApiClient.dio;

  // ---------- validate ----------
  Future<bool> validateHash(String code) async {
    final res = await _dio.post(
      '/assesment/validate_hash',
      data: {'hash': code},
    );
    return (res.data['valid'] == true);
  }

  // ---------- RIASEC ----------
  Future<List<RiasecQuestion>> getRiasecQuestions() async {
    final res = await _dio.get('/assesment/test/riasec/question');
    return (res.data['data'] as List)
        .map((e) => RiasecQuestion.fromJson(e))
        .toList();
  }

  Future<void> submitRiasec(Map<int, int> answers) async {
    // kirim format yang backend minta
    await _dio.post('/assesment/test/riasec/submit', data: {
      'answers': answers.entries
          .map((e) => {'id': e.key, 'value': e.value}) // 0..4
          .toList(),
    });
  }

  Future<RiasecResult> getRiasecResult() async {
    final res = await _dio.get('/assesment/test/riasec/result');
    return RiasecResult.fromJson(res.data['data']);
  }

  // ---------- IKIGAI ----------
  Future<List<IkigaiQuestion>> getIkigaiQuestions() async {
    final res = await _dio.get('/assesment/test/ikigai/question');
    return (res.data['data'] as List)
        .map((e) => IkigaiQuestion.fromJson(e))
        .toList();
  }

  Future<void> submitIkigai(
      Map<int, Set<int>> selections,
      Map<int, String> reasons,
      ) async {
    final payload = selections.entries
        .map((e) => {
      'id': e.key,
      'options': e.value.toList(),
      'reason': reasons[e.key] ?? '',
    })
        .toList();
    await _dio.post('/assesment/test/ikigai/submit', data: {'answers': payload});
  }

  Future<IkigaiResult> getIkigaiResult() async {
    final res = await _dio.get('/assesment/test/ikigai/result');
    return IkigaiResult.fromJson(res.data['data']);
  }
}
