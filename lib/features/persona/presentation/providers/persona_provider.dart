import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rextra_app/features/persona/domain/persona_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State untuk menyimpan jawaban kuisioner sementara
class PersonaState {
  final bool? tujuan;
  final bool? porto;
  final bool? rekrut;
  final PersonaType? finalPersona;

  PersonaState({this.tujuan, this.porto, this.rekrut, this.finalPersona});

  PersonaState copyWith({
    bool? tujuan,
    bool? porto,
    bool? rekrut,
    PersonaType? finalPersona,
  }) {
    return PersonaState(
      tujuan: tujuan ?? this.tujuan,
      porto: porto ?? this.porto,
      rekrut: rekrut ?? this.rekrut,
      finalPersona: finalPersona ?? this.finalPersona,
    );
  }
}

class PersonaNotifier extends StateNotifier<PersonaState> {
  PersonaNotifier() : super(PersonaState());

  static const _key = 'last_persona';

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
    state = state.copyWith(finalPersona: type);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, type.name);
  }
}

// Global Provider yang bisa diakses di seluruh halaman persona
final personaProvider = StateNotifierProvider<PersonaNotifier, PersonaState>((ref) {
  return PersonaNotifier();
});