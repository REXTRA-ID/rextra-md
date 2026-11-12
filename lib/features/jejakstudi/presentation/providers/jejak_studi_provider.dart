import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../persona/data/persona_repository.dart';
import '../../../persona/presentation/providers/persona_provider.dart';
import '../../data/education_repository.dart';
import '../../domain/education_models.dart';

const educationMissionKey = 'education_saved';

final educationRepositoryProvider =
    Provider<EducationRepository>((_) => EducationRepository());

final jejakPersonaRepositoryProvider =
    Provider<PersonaRepository>((_) => PersonaRepository());

final jejakStudiProvider =
    AsyncNotifierProvider<JejakStudiNotifier, EducationData>(
        JejakStudiNotifier.new);

class JejakStudiNotifier extends AsyncNotifier<EducationData> {
  EducationRepository get _repo => ref.read(educationRepositoryProvider);

  @override
  Future<EducationData> build() => _repo.load();

  EducationData get _data => state.valueOrNull ?? const EducationData();

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> saveOngoing(OngoingEducation e) async {
    await _commit(EducationData(ongoing: e, completed: _data.completed));
    await _completeMission();
  }

  Future<void> deleteOngoing() =>
      _commit(EducationData(completed: _data.completed));

  /// Simpan / perbarui riwayat studi. Kalau [finishedOngoingId] diisi,
  /// pendidikan yang sedang ditempuh itu ikut dihapus (alur "Selesaikan
  /// Status").
  Future<void> saveCompleted(CompletedEducation e,
      {String? finishedOngoingId}) async {
    final list = [..._data.completed];
    final i = list.indexWhere((c) => c.id == e.id);
    if (i >= 0) {
      list[i] = e;
    } else {
      list.insert(0, e);
    }
    final ongoing = _data.ongoing;
    await _commit(EducationData(
      ongoing:
          ongoing != null && ongoing.id == finishedOngoingId ? null : ongoing,
      completed: list,
    ));
    await _completeMission();
  }

  Future<void> deleteCompleted(String id) => _commit(EducationData(
        ongoing: _data.ongoing,
        completed: _data.completed.where((c) => c.id != id).toList(),
      ));

  Future<void> _commit(EducationData next) async {
    await _repo.save(next);
    state = AsyncData(next);
  }

  /// Misi wajib "Simpan Data Pendidikan" selesai begitu ada data
  /// pendidikan yang tersimpan.
  Future<void> _completeMission() async {
    final persona = ref.read(personaProvider);
    if (persona.missionStatus[educationMissionKey] == true) return;
    try {
      await ref
          .read(jejakPersonaRepositoryProvider)
          .completeMission(educationMissionKey);
      await ref.read(personaProvider.notifier).fetchExistingPersona();
    } catch (_) {
      // Gagal update misi (mis. offline) -> data tetap tersimpan lokal,
      // misi dicoba lagi saat simpan berikutnya.
    }
  }
}
