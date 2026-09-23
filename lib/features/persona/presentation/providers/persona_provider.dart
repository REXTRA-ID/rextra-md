import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rextra_app/features/persona/data/persona_repository.dart';
import 'package:rextra_app/features/persona/domain/persona_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State untuk menyimpan jawaban kuisioner sementara
class PersonaState {
  final bool? tujuan;
  final bool? porto;
  final bool? rekrut;
  final PersonaType? finalPersona;
  final int completedMissions;
  final int totalMissions;

  /// Status selesai/belum tiap misi, terurut (index 0 = misi pertama).
  final List<bool> missionsCompleted;

  PersonaState({
    this.tujuan,
    this.porto,
    this.rekrut,
    this.finalPersona,
    this.completedMissions = 0,
    this.totalMissions = 0,
    this.missionsCompleted = const [],
  });

  /// Apakah semua misi wajib persona ini sudah diselesaikan.
  bool get missionsComplete =>
      totalMissions > 0 && completedMissions >= totalMissions;

  PersonaState copyWith({
    bool? tujuan,
    bool? porto,
    bool? rekrut,
    PersonaType? finalPersona,
    int? completedMissions,
    int? totalMissions,
    List<bool>? missionsCompleted,
  }) {
    return PersonaState(
      tujuan: tujuan ?? this.tujuan,
      porto: porto ?? this.porto,
      rekrut: rekrut ?? this.rekrut,
      finalPersona: finalPersona ?? this.finalPersona,
      completedMissions: completedMissions ?? this.completedMissions,
      totalMissions: totalMissions ?? this.totalMissions,
      missionsCompleted: missionsCompleted ?? this.missionsCompleted,
    );
  }
}

/// Jumlah misi wajib per tipe persona, sesuai konstanta di backend
/// (missionLimitPathfinder/Builder/Achiever).
int missionLimitFor(PersonaType type) {
  switch (type) {
    case PersonaType.pathfinder:
      return 4;
    case PersonaType.builder:
      return 7;
    case PersonaType.achiever:
      return 9;
  }
}

class PersonaNotifier extends StateNotifier<PersonaState> {
  PersonaNotifier() : super(PersonaState());

  final _repo = PersonaRepository();
  static const _key = 'last_persona';

  /// Cek ke backend apakah user sudah pernah menyelesaikan asesmen persona
  /// sebelumnya. Kalau ada, state & cache lokal langsung diisi (termasuk
  /// progres misi wajibnya) supaya asesmen tidak perlu diulang setelah
  /// login ulang.
  Future<PersonaStatus?> fetchExistingPersona() async {
    try {
      final status = await _repo.getPersona();
      if (status != null) {
        state = state.copyWith(
          finalPersona: status.type,
          completedMissions: status.completedMissions,
          totalMissions: status.totalMissions,
          missionsCompleted: status.missionsCompleted,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_key, status.type.name);
      }
      return status;
    } catch (_) {
      // Gagal cek ke server (mis. offline) -> anggap belum ada,
      // biar user tetap bisa lanjut asesmen seperti biasa.
      return null;
    }
  }

  // Menyimpan jawaban step 1
  void setTujuan(bool value) {
    state = state.copyWith(tujuan: value);
  }

  // Menyimpan jawaban step 2
  void setPorto(bool value) {
    state = state.copyWith(porto: value);
  }

  // Menghitung hasil akhir dan menyimpan ke SharedPreferences
  Future<void> calculateAndSaveResult(bool rekrutValue) async {
    final type = resolvePersona(
      tujuan: state.tujuan ?? false,
      porto: state.porto ?? false,
      rekrut: rekrutValue,
    );

    state = state.copyWith(rekrut: rekrutValue, finalPersona: type);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, type.name);
  }

  // Early decision save (Jika user jawab "Tidak" di awal)
  Future<void> saveEarlyDecision(PersonaType type) async {
    state = state.copyWith(
      finalPersona: type,
      completedMissions: 0,
      totalMissions: missionLimitFor(type),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, type.name);

    // Simpan juga ke backend supaya hasilnya tidak hilang & tidak perlu
    // asesmen ulang setelah login ulang / ganti perangkat.
    try {
      await _repo.createPersona(type);
    } catch (_) {
      // Gagal simpan ke server (mis. offline) -> tetap lanjut,
      // hasil masih tersimpan lokal di SharedPreferences.
    }
  }
}

// Global Provider yang bisa diakses di seluruh halaman persona
final personaProvider =
    StateNotifierProvider<PersonaNotifier, PersonaState>((ref) {
  return PersonaNotifier();
});
