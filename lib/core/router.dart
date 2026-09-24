import 'package:go_router/go_router.dart';
import 'package:rextra_app/features/persona/presentation/persona_info_page.dart';
import 'package:rextra_app/features/persona/presentation/persona_intro_page.dart';
import 'package:rextra_app/features/persona/presentation/persona_quistionarre_page.dart';
import 'package:rextra_app/features/persona/presentation/persona_result_page.dart';
import 'package:rextra_app/features/persona/presentation/persona_reveal_page.dart';
import 'package:rextra_app/features/persona/presentation/persona_welcome_page.dart';

// AUTH
import '../features/auth/presentation/forgot_password_pages.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/onboarding_pager.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/auth/presentation/verify_email_page.dart';
import '../features/auth/presentation/verification_result_page.dart';
import 'storage/secure_storage.dart';

// HOME (sementara)
import 'package:rextra_app/features/home/presentation/home_page.dart';

// PERSONA (Flow 2)

// KENALI DIRI
import '../features/kenalidiri/presentation/kenalidiri_pages.dart';
import '../features/kenalidiri/presentation/hasil_kenalidiri_page.dart';
import '../features/kenalidiri/presentation/kenalidiri_history_page.dart';

// Halaman yang tidak boleh diakses lagi kalau sesi login masih aktif —
// mencegah user "kembali" ke sini lewat tombol back browser setelah login.
const _authOnlyPaths = <String>{
  '/splash',
  '/onboarding',
  '/login',
  '/register',
};

// Halaman yang boleh diakses tanpa login. Selain daftar ini dianggap
// halaman yang butuh login (default-deny), supaya rute baru otomatis
// terlindungi tanpa perlu didaftarkan manual satu-satu.
const _publicPaths = <String>{
  '/splash',
  '/onboarding',
  '/login',
  '/register',
  '/verify',
  '/verifikasi-akun',
  '/forgot',
  '/forgot/sent',
  '/forgot/expired',
  '/forgot/new',
  '/forgot/success',
};

final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final token = await AppSecureStorage.readToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    final path = state.matchedLocation;

    if (isLoggedIn && _authOnlyPaths.contains(path)) {
      return '/home';
    }
    if (!isLoggedIn && !_publicPaths.contains(path)) {
      return '/login';
    }
    return null;
  },
  routes: [
    // --- Splash & onboarding ---
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPager()),

    // --- Auth ---
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(
      path: '/verify',
      builder: (ctx, s) => VerifyEmailPage(
        email: s.uri.queryParameters['email'] ?? '',
        mode: s.uri.queryParameters['mode'] ?? 'sent', // sent|resent|expired
      ),
    ),
    GoRoute(
      path: '/verifikasi-akun',
      builder: (ctx, s) => VerificationResultPage(
        token: s.uri.queryParameters['token'] ?? '',
      ),
    ),

    // --- Forgot password flow ---
    GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordRequestPage()),
    GoRoute(
      path: '/forgot/sent',
      builder: (_, s) => ForgotPasswordSentPage(email: s.uri.queryParameters['email'] ?? ''),
    ),
    GoRoute(
      path: '/forgot/expired',
      builder: (_, s) => ForgotPasswordExpiredPage(email: s.uri.queryParameters['email'] ?? ''),
    ),
    GoRoute(
      path: '/forgot/new',
      builder: (_, s) => NewPasswordPage(token: s.uri.queryParameters['token'] ?? ''),
    ),
    GoRoute(path: '/forgot/success', builder: (_, __) => const PasswordResetSuccessPage()),

    // --- Persona (Flow 2) ---
    GoRoute(path: '/persona/welcome', builder: (_, __) => const PersonaWelcomePage()),
    GoRoute(path: '/persona/info', builder:  (_, __) => const PersonaInfoDetailPage()),
    GoRoute(path: '/persona/intro', builder:  (_, __) => const PersonaIntroPage()),
    // GoRoute(
    //   path: '/persona/step1',
    //   builder: (_, __) => const PersonaStepPage(
    //     step: 1,
    //     title: 'Tujuan Karier',
    //     bannerAsset: 'assets/images/tujuan.png',
    //     optYes: 'Iya, saya sudah punya',
    //     optNo: 'Tidak, Saya belum punya',
    //   ),
    // ),
    // GoRoute(
    //   path: '/persona/step2',
    //   builder: (_, s) {
    //     final tujuan = (s.extra is Map && (s.extra as Map)['tujuan'] == true);
    //     return PersonaStepPage(
    //       step: 2,
    //       title: 'Portofolio Karier',
    //       bannerAsset: 'assets/images/porto.png',
    //       optYes: 'Iya, saya sedang membangun portofolio',
    //       optNo: 'Tidak, saya belum punya',
    //       sebelumnyaTujuan: tujuan,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: '/persona/step3',
    //   builder: (_, s) {
    //     final m = (s.extra is Map) ? s.extra as Map : {};
    //     return PersonaStepPage(
    //       step: 3,
    //       title: 'Rekrutmen Kerja',
    //       bannerAsset: 'assets/images/rekrutmen.png',
    //       optYes: 'Iya, saya sedang ikut',
    //       optNo: 'Tidak, saya belum ikut',
    //       sebelumnyaTujuan: m['tujuan'] == true,
    //       sebelumnyaPorto:  m['porto']  == true,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: '/persona/result',
    //   builder: (_, s) {
    //     final type = (s.extra is Map && (s.extra as Map)['type'] is PersonaType)
    //         ? (s.extra as Map)['type'] as PersonaType
    //         : PersonaType.pathfinder;
    //     return PersonaResultPage(type: type);
    //   },
    // ),
    GoRoute(
      path: '/persona/quistionnaire',
      builder: (_, __) => const PersonaQuestionnairePage(),
    ),
    GoRoute(
      path: '/persona/reveal',
      builder: (_, __) => const PersonaRevealPage(),
    ),
    GoRoute(
      path: '/persona/result',
      builder: (_, __) => const PersonaResultPage(),
    ),

    // --- Placeholder Home (sementara)
    GoRoute(
      path: '/home',
      builder: (_, s) => HomePage(
        initialTab: s.uri.queryParameters['tab'] == 'profile' ? 4 : 0,
      ),
    ),

    // --- Kenali Diri
    GoRoute(path: '/kenali', builder: (_, __) => const KenaliDiriInfoPage()),
    GoRoute(path: '/kenali/riasec-intro', builder: (_, __) => const RiasecIntroPage()),
    GoRoute(path: '/kenali/ikigai-intro', builder:  (_, __) => const IkigaiIntroPage()),
    GoRoute(path: '/kenali/riasec-test', builder: (_, __) => const RiasecTestPage()),
    GoRoute(path: '/kenali/ikigai-test', builder:  (_, __) => const IkigaiTestPage()),
    GoRoute(path: '/kenali/result', builder: (_, __) => const HasilKenaliDiriPage()),
    GoRoute(path: '/kenali/history', builder: (_, __) => const KenaliDiriHistoryPage()),
  ],
);
