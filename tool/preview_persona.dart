// Preview lokal halaman hasil persona tanpa login/backend.
// Jalankan: flutter run -d chrome -t tool/preview_persona.dart
// Ganti persona via URL: ?p=pathfinder|builder|achiever
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rextra_app/features/persona/domain/persona_models.dart';
import 'package:rextra_app/features/persona/presentation/persona_result_page.dart';
import 'package:rextra_app/features/persona/presentation/providers/persona_provider.dart';

class _FakePersonaNotifier extends PersonaNotifier {
  _FakePersonaNotifier(PersonaState initial) {
    state = initial;
  }

  @override
  Future<Null> fetchExistingPersona() async => null;
}

void main() {
  final name = Uri.base.queryParameters['p'] ?? 'builder';
  final type = PersonaType.values.firstWhere((t) => t.name == name,
      orElse: () => PersonaType.builder);
  final total = missionsFor(type).length;

  runApp(ProviderScope(
    overrides: [
      personaProvider.overrideWith((ref) => _FakePersonaNotifier(PersonaState(
            finalPersona: type,
            completedMissions: 1,
            totalMissions: total,
            missionStatus: const {'education_saved': true},
          ))),
    ],
    child: ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Poppins'),
        home: const PersonaResultPage(),
      ),
    ),
  ));
}
