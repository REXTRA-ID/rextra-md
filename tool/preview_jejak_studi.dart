// Preview lokal Jejak Studi tanpa login/backend (data di memori).
// Jalankan: flutter run -d chrome -t tool/preview_jejak_studi.dart
// Pilih kondisi via URL: ?s=kosong|normal|transisi|akhir
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rextra_app/features/jejakstudi/data/education_repository.dart';
import 'package:rextra_app/features/jejakstudi/domain/education_models.dart';
import 'package:rextra_app/features/jejakstudi/presentation/education_detail_page.dart';
import 'package:rextra_app/features/jejakstudi/presentation/education_form_pages.dart';
import 'package:rextra_app/features/jejakstudi/presentation/jejak_studi_home_page.dart';
import 'package:rextra_app/features/jejakstudi/presentation/jejak_studi_success_page.dart';
import 'package:rextra_app/features/jejakstudi/presentation/providers/jejak_studi_provider.dart';
import 'package:rextra_app/features/persona/data/persona_repository.dart';
import 'package:rextra_app/features/persona/presentation/providers/persona_provider.dart';

class _MemoryRepo extends EducationRepository {
  EducationData data;
  _MemoryRepo(this.data);

  @override
  Future<EducationData> load() async => data;

  @override
  Future<void> save(EducationData d) async => data = d;
}

class _NoopPersonaRepo extends PersonaRepository {
  @override
  Future<void> completeMission(String missionKey) async {}
}

class _FakePersonaNotifier extends PersonaNotifier {
  @override
  Future<Null> fetchExistingPersona() async => null;
}

EducationData _seed(String s) {
  if (s == 'kosong') return const EducationData();
  final now = MonthYear.now();
  final ongoing = OngoingEducation(
    id: 'o1',
    level: EducationLevel.s1,
    university: 'Institut Teknologi Sepuluh Nopember',
    faculty: 'Fakultas Teknologi Elektro dan Informatika Cerdas',
    program: 'Sistem Informasi',
    startDate: const MonthYear(2021, 8),
    estimatedGraduation: s == 'akhir' ? now : const MonthYear(2027, 6),
    currentSemester: s == 'akhir' ? 8 : 7,
    currentSemesterStart: const MonthYear(2026, 6),
    nextSemester: s == 'akhir' ? 9 : 8,
    nextSemesterStart:
        s == 'transisi' ? const MonthYear(2026, 9) : const MonthYear(2099, 12),
    gpa: 3.6,
    isFinalSemester: s == 'akhir',
  );
  return EducationData(ongoing: ongoing, completed: const [
    CompletedEducation(
      id: 'c1',
      type: CompletedStudyType.reguler,
      level: EducationLevel.d3,
      university: 'Universitas Brawijaya',
      faculty: 'Fakultas Ilmu Komputer',
      program: 'Ilmu Komputer',
      startDate: MonthYear(2018, 8),
      endDate: MonthYear(2022, 6),
      totalSemesters: 6,
      finalGpa: 3.7,
    ),
    CompletedEducation(
      id: 'c2',
      type: CompletedStudyType.studentExchange,
      level: EducationLevel.s1,
      university: 'Institut Teknologi Sepuluh Nopember',
      program: 'Sistem Informasi',
      startDate: MonthYear(2024, 2),
      endDate: MonthYear(2024, 7),
      exchangeProgram: 'IISMA',
      hostUniversity: 'National Taiwan University',
      hostCountry: 'Taiwan',
    ),
  ]);
}

void main() {
  final s = Uri.base.queryParameters['s'] ?? 'normal';
  final router = GoRouter(initialLocation: '/jejak-studi', routes: [
    GoRoute(
        path: '/persona/result',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('persona')))),
    GoRoute(
        path: '/jejak-studi', builder: (_, __) => const JejakStudiHomePage()),
    GoRoute(
        path: '/jejak-studi/ditempuh',
        builder: (_, st) =>
            OngoingEducationFormPage(editId: st.uri.queryParameters['id'])),
    GoRoute(
        path: '/jejak-studi/selesai',
        builder: (_, st) => CompletedEducationFormPage(
              editId: st.uri.queryParameters['id'],
              fromOngoingId: st.uri.queryParameters['dari'],
            )),
    GoRoute(
        path: '/jejak-studi/detail/:id',
        builder: (_, st) => EducationDetailPage(id: st.pathParameters['id']!)),
    GoRoute(
        path: '/jejak-studi/riwayat',
        builder: (_, __) => const EducationHistoryPage()),
    GoRoute(
        path: '/jejak-studi/berhasil',
        builder: (_, st) => JejakStudiSuccessPage(
            deleted: st.uri.queryParameters['aksi'] == 'hapus')),
  ]);

  runApp(ProviderScope(
    overrides: [
      educationRepositoryProvider.overrideWithValue(_MemoryRepo(_seed(s))),
      jejakPersonaRepositoryProvider.overrideWithValue(_NoopPersonaRepo()),
      personaProvider.overrideWith((_) => _FakePersonaNotifier()),
    ],
    child: ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (_, __) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Poppins'),
        routerConfig: router,
      ),
    ),
  ));
}
