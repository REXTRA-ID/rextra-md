import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rextra_app/features/persona/domain/persona_models.dart';
import 'package:rextra_app/features/persona/presentation/persona_result_page.dart';
import 'package:rextra_app/features/persona/presentation/providers/persona_provider.dart';

/// Notifier yang tidak memanggil backend.
class _FakePersonaNotifier extends PersonaNotifier {
  _FakePersonaNotifier(PersonaState initial) {
    state = initial;
  }

  @override
  Future<Null> fetchExistingPersona() async => null;
}

void main() {
  test('progres dihitung dari daftar misi Figma per key', () {
    const status = {'education_saved': true, 'cv_created': true};
    expect(missionsFor(PersonaType.pathfinder).length, 4);
    expect(missionsFor(PersonaType.builder).length, 5);
    expect(missionsFor(PersonaType.achiever).length, 5);
    // cv_created bukan misi di daftar Figma -> tidak ikut dihitung.
    expect(completedMissionCount(PersonaType.builder, status), 1);
  });

  for (final type in PersonaType.values) {
    testWidgets('halaman hasil ${type.name} render tanpa overflow',
        (tester) async {
      // Viewport tinggi supaya semua tile terlihat (tidak ketutup bottom sheet).
      tester.view.physicalSize = const Size(393 * 3, 3000 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          personaProvider.overrideWith((ref) => _FakePersonaNotifier(
                PersonaState(
                  finalPersona: type,
                  missionStatus: const {'education_saved': true},
                ),
              )),
        ],
        child: const MaterialApp(home: PersonaResultPage()),
      ));
      await tester.pump();

      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('1 '), findsNothing); // teks progres pakai TextSpan

      // Buka semua panel detail.
      final tiles = find.byIcon(Icons.keyboard_arrow_down_rounded);
      final count = tiles.evaluate().length;
      expect(count, missionsFor(type).length);
      for (var i = 0; i < count; i++) {
        final t = find.byIcon(Icons.keyboard_arrow_down_rounded).first;
        await tester.ensureVisible(t);
        await tester.tap(t);
        await tester.pump();
      }
      expect(find.text('Kerjakan Misi'), findsNWidgets(count));

      // Tidak ada tombol profil (user harus lewat perkenalan misi dulu).
      expect(find.byIcon(Icons.account_circle), findsNothing);

      // "Lihat Selengkapnya" membuka teks tambahan dan bisa ditutup lagi.
      await tester.ensureVisible(find.text('Lihat Selengkapnya'));
      await tester.tap(find.text('Lihat Selengkapnya'));
      await tester.pump();
      expect(find.text('Sembunyikan'), findsOneWidget);
      expect(find.textContaining('adalah mahasiswa'), findsOneWidget);
      await tester.tap(find.text('Sembunyikan'));
      await tester.pump();
      expect(find.textContaining('adalah mahasiswa'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
