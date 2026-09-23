import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/persona_models.dart';

/// Persona milik user beserta progres misi wajibnya, sesuai respons
/// `GET /persona` di backend.
class PersonaStatus {
  final PersonaType type;
  final int completedMissions;
  final int totalMissions;

  /// Status selesai/belum tiap misi, terurut sesuai `order` dari backend
  /// (index 0 = misi pertama, dst).
  final List<bool> missionsCompleted;

  const PersonaStatus({
    required this.type,
    required this.completedMissions,
    required this.totalMissions,
    this.missionsCompleted = const [],
  });

  bool get isComplete =>
      totalMissions > 0 && completedMissions >= totalMissions;
}

/// Menyimpan & mengambil hasil asesmen persona dari backend, supaya user
/// tidak perlu mengulang asesmen setiap kali login ulang.
class PersonaRepository {
  final Dio _dio = ApiClient.dio;

  /// Ambil persona milik user yang sedang login.
  /// Null artinya user belum pernah menyelesaikan asesmen persona.
  Future<PersonaStatus?> getPersona() async {
    final res = await _dio.get('/persona');
    if (res.statusCode != 200) return null;

    final body = res.data;
    if (body is! Map || body['data'] is! Map) return null;
    final data = body['data'] as Map;

    final type = _parseType(data['persona_type'] as String?);
    if (type == null) return null;

    final progress = data['progress'];
    final completed = progress is Map
        ? (progress['completed_missions'] as num?)?.toInt() ?? 0
        : 0;
    final total = progress is Map
        ? (progress['total_missions'] as num?)?.toInt() ?? 0
        : 0;

    final missionsRaw = data['missions'];
    var missionsCompleted = <bool>[];
    if (missionsRaw is List) {
      final sorted = List.of(missionsRaw)
        ..sort((a, b) {
          final orderA = (a is Map ? a['order'] as num? : null) ?? 0;
          final orderB = (b is Map ? b['order'] as num? : null) ?? 0;
          return orderA.compareTo(orderB);
        });
      missionsCompleted =
          sorted.map((m) => m is Map && m['is_completed'] == true).toList();
    }

    return PersonaStatus(
      type: type,
      completedMissions: completed,
      totalMissions: total,
      missionsCompleted: missionsCompleted,
    );
  }

  /// Tandai satu misi wajib sebagai selesai di backend.
  /// [missionKey] harus salah satu key misi statis, mis. "career_recommendation_tried".
  Future<void> completeMission(String missionKey) async {
    await _dio.put('/persona/mission/complete', data: {
      'mission_key': missionKey,
    });
  }

  /// Simpan hasil asesmen ke backend. Aman dipanggil berkali-kali —
  /// jika persona sudah ada di server, backend akan menolak (409) dan
  /// itu tidak dianggap error di sini.
  Future<void> createPersona(PersonaType type) async {
    final flags = _flagsFor(type);
    await _dio.post('/persona/create', data: {
      'has_career_goal': flags.$1,
      'building_portofolio': flags.$2,
      'in_recruitment_process': flags.$3,
    });
  }

  PersonaType? _parseType(String? raw) {
    switch (raw) {
      case 'pathfinder':
        return PersonaType.pathfinder;
      case 'builder':
        return PersonaType.builder;
      case 'achiever':
        return PersonaType.achiever;
      default:
        return null;
    }
  }

  /// Backend menyimpulkan tipe dari 3 boolean sekaligus (semua "iya" ->
  /// Achiever, semua "tidak" -> Pathfinder, campuran -> Builder). Alur
  /// asesmen di app sekarang cuma 2 pertanyaan, jadi boolean ketiga di sini
  /// cuma pelengkap agar hasil akhirnya tetap sama dengan [type] yang sudah
  /// ditentukan oleh logika di app.
  (bool, bool, bool) _flagsFor(PersonaType type) {
    switch (type) {
      case PersonaType.pathfinder:
        return (false, false, false);
      case PersonaType.builder:
        return (true, false, false);
      case PersonaType.achiever:
        return (true, true, true);
    }
  }
}
