import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rextra_app/features/jejakstudi/data/education_repository.dart';
import 'package:rextra_app/features/jejakstudi/domain/education_models.dart';
import 'package:rextra_app/features/jejakstudi/presentation/education_form_pages.dart';
import 'package:rextra_app/features/jejakstudi/presentation/jejak_studi_home_page.dart';
import 'package:rextra_app/features/jejakstudi/presentation/providers/jejak_studi_provider.dart';
import 'package:rextra_app/features/persona/data/persona_repository.dart';
import 'package:rextra_app/features/persona/presentation/providers/persona_provider.dart';

class _MemoryRepo extends EducationRepository {
  EducationData data;
  _MemoryRepo([this.data = const EducationData()]);

  @override
  Future<EducationData> load() async => data;

  @override
  Future<void> save(EducationData d) async => data = d;
}

class _FakePersonaRepo extends PersonaRepository {
  final completed = <String>[];

  @override
  Future<void> completeMission(String missionKey) async =>
      completed.add(missionKey);
}

class _FakePersonaNotifier extends PersonaNotifier {
  @override
  Future<Null> fetchExistingPersona() async => null;
}

OngoingEducation _ongoing({
  MonthYear next = const MonthYear(2099, 2),
  bool isFinal = false,
  MonthYear grad = const MonthYear(2099, 8),
}) =>
    OngoingEducation(
      id: 'o1',
      level: EducationLevel.s1,
      university: 'Institut Teknologi Sepuluh Nopember',
      faculty: 'FTEIC',
      program: 'Sistem Informasi',
      startDate: const MonthYear(2021, 8),
      estimatedGraduation: grad,
      currentSemester: 7,
      currentSemesterStart: const MonthYear(2026, 6),
      nextSemester: 8,
      nextSemesterStart: next,
      gpa: 3.6,
      isFinalSemester: isFinal,
    );

void main() {
  group('model', () {
    test('JSON roundtrip ongoing + completed', () {
      final data = EducationData(
        ongoing: _ongoing(),
        completed: const [
          CompletedEducation(
            id: 'c1',
            type: CompletedStudyType.studentExchange,
            level: EducationLevel.s1,
            university: 'Universitas Airlangga',
            program: 'Manajemen',
            startDate: MonthYear(2023, 2),
            endDate: MonthYear(2023, 7),
            exchangeProgram: 'IISMA',
            hostUniversity: 'Universitas C',
            hostCountry: 'Taiwan',
          ),
        ],
      );
      final back =
          EducationData.fromJson(jsonDecode(jsonEncode(data.toJson())));
      expect(back.ongoing!.program, 'Sistem Informasi');
      expect(back.ongoing!.nextSemesterStart, const MonthYear(2099, 2));
      expect(back.completed.single.hostCountry, 'Taiwan');
      expect(back.completed.single.title, 'Exchange - IISMA');
      expect(back.completed.single.yearRange, '2023');
    });

    test('data rusak -> kosong, bukan crash', () {
      expect(EducationData.fromJson('x').isEmpty, isTrue);
      expect(
          EducationData.fromJson({
            'ongoing': {'level': 'zz'}
          }).isEmpty,
          isTrue);
    });

    test('parseGpa', () {
      expect(parseGpa('3,75'), 3.75);
      expect(parseGpa('4'), 4);
      expect(parseGpa('4.1'), isNull);
      expect(parseGpa('abc'), isNull);
    });

    test('pengingat transisi semester & kelulusan', () {
      const now = MonthYear(2026, 12);
      expect(_ongoing(next: const MonthYear(2026, 12)).needsSemesterUpdate(now),
          isTrue);
      expect(_ongoing(next: const MonthYear(2027, 1)).needsSemesterUpdate(now),
          isFalse);
      final last = _ongoing(isFinal: true, grad: const MonthYear(2026, 11));
      expect(last.needsSemesterUpdate(now), isFalse);
      expect(last.needsGraduationUpdate(now), isTrue);
    });

    test('userIdFromToken baca claim user_id', () {
      String b64(Map m) =>
          base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
      final token = '${b64({'alg': 'HS256'})}.${b64({'user_id': 'u-123'})}.sig';
      expect(userIdFromToken(token), 'u-123');
      expect(userIdFromToken('bukan-jwt'), isNull);
      expect(userIdFromToken(null), isNull);
    });
  });

  group('halaman', () {
    late _MemoryRepo repo;
    late _FakePersonaRepo personaRepo;

    Future<void> pump(WidgetTester tester, String location) async {
      tester.view.physicalSize = const Size(393 * 3, 2400 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final router = GoRouter(initialLocation: location, routes: [
        GoRoute(
            path: '/jejak-studi',
            builder: (_, __) => const JejakStudiHomePage()),
        GoRoute(
            path: '/jejak-studi/ditempuh',
            builder: (_, s) =>
                OngoingEducationFormPage(editId: s.uri.queryParameters['id'])),
        GoRoute(
            path: '/jejak-studi/selesai',
            builder: (_, __) => const CompletedEducationFormPage()),
        GoRoute(
            path: '/jejak-studi/detail/:id',
            builder: (_, s) => Text('DETAIL ${s.pathParameters['id']}')),
        GoRoute(
            path: '/jejak-studi/berhasil',
            builder: (_, __) => const Text('BERHASIL')),
      ]);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          educationRepositoryProvider.overrideWithValue(repo),
          jejakPersonaRepositoryProvider.overrideWithValue(personaRepo),
          personaProvider.overrideWith((_) => _FakePersonaNotifier()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
    }

    setUp(() {
      repo = _MemoryRepo();
      personaRepo = _FakePersonaRepo();
    });

    testWidgets('status kosong -> tombol Isi Status buka form ditempuh',
        (tester) async {
      await pump(tester, '/jejak-studi');
      expect(find.text('Belum ada status pendidikan aktif'), findsOneWidget);
      expect(find.text('Riwayat Studi'), findsNothing);

      await tester.tap(find.text('Isi Status'));
      await tester.pumpAndSettle();
      expect(find.text('Tambah Studi Ditempuh'), findsOneWidget);
    });

    testWidgets('status normal + riwayat tampil, pengingat semester muncul',
        (tester) async {
      repo = _MemoryRepo(EducationData(
        ongoing: _ongoing(next: const MonthYear(2020, 1)),
        completed: const [
          CompletedEducation(
            id: 'c1',
            type: CompletedStudyType.reguler,
            level: EducationLevel.d3,
            university: 'Universitas Brawijaya',
            program: 'Ilmu Komputer',
            startDate: MonthYear(2018, 8),
            endDate: MonthYear(2022, 6),
            totalSemesters: 6,
            finalGpa: 3.5,
          ),
        ],
      ));
      await pump(tester, '/jejak-studi');
      expect(find.text('S1 - SISTEM INFORMASI'), findsOneWidget);
      expect(find.text('IPK 3.60'), findsOneWidget);
      expect(find.text('SEMESTER 7'), findsOneWidget);
      expect(find.textContaining('Sepertinya sudah berganti semester'),
          findsOneWidget);
      expect(find.text('D3 - Ilmu Komputer'), findsOneWidget);
      expect(find.text('2018-2022'), findsOneWidget);
    });

    testWidgets('form ditempuh kosong -> semua pesan error Figma',
        (tester) async {
      await pump(tester, '/jejak-studi/ditempuh');
      await tester.tap(find.text('Simpan Data'));
      await tester.pumpAndSettle();
      for (final msg in [
        'Jenjang pendidikan wajib dipilih',
        'Nama perguruan tinggi wajib diisi',
        'Nama fakultas wajib diisi',
        'Program studi wajib diisi',
        'Tanggal mulai perkuliahan wajib diisi',
        'Estimasi kelulusan wajib diisi',
        'Semester saat ini wajib diisi',
        'Periode mulai semester saat ini wajib diisi',
        'Semester berikutnya wajib diisi',
        'Perkiraan semester berikutnya wajib diisi',
        'IPK saat ini wajib diisi',
      ]) {
        expect(find.text(msg), findsOneWidget, reason: msg);
      }
      expect(repo.data.isEmpty, isTrue);
    });

    testWidgets('edit ditempuh -> simpan & tandai misi education_saved',
        (tester) async {
      repo = _MemoryRepo(EducationData(ongoing: _ongoing()));
      await pump(tester, '/jejak-studi/ditempuh?id=o1');
      expect(find.text('Edit Studi Ditempuh'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, '3.60'), '3.80');
      await tester.tap(find.text('Simpan Data'));
      await tester.pumpAndSettle();

      expect(repo.data.ongoing!.gpa, 3.8);
      expect(personaRepo.completed, ['education_saved']);
    });

    testWidgets('form diselesaikan: Student Exchange ganti field',
        (tester) async {
      await pump(tester, '/jejak-studi/selesai');
      expect(find.text('Total Semester Ditempuh'), findsOneWidget);
      expect(find.text('Nama Program Exchange'), findsNothing);

      await tester.tap(find.text('Reguler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Student Exchange'));
      await tester.pumpAndSettle();

      expect(find.text('Nama Program Exchange'), findsOneWidget);
      expect(find.text('Negara Tujuan'), findsOneWidget);
      expect(find.text('Total Semester Ditempuh'), findsNothing);
    });
  });
}
