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

// HOME (sementara)
import 'package:rextra_app/features/home/presentation/home_page.dart';

// PERSONA (Flow 2)
import '../features/kenalidiri/presentation/kenalidiri_history_page.dart';
import '../features/kenalidiri/presentation/kenalidiri_home_page.dart';
import '../features/persona/presentation/persona_pages.dart';
import '../features/kenalidiri/presentation/kenalidiri_pages.dart';
import '../features/kenalidiri/presentation/hasil_kenalidiri_page.dart';

final router = GoRouter(
  initialLocation: '/persona/welcome',
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
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),

    // --- Kenali Diri
    GoRoute(path: '/kenali/riasec-intro', builder: (_, __) => const RiasecIntroPage()),
    GoRoute(path: '/kenali/ikigai-intro', builder:  (_, __) => const IkigaiIntroPage()),
    GoRoute(path: '/kenali/riasec-test', builder: (_, __) => const RiasecTestPage()),
    GoRoute(path: '/kenali/ikigai-test', builder:  (_, __) => const IkigaiTestPage()),
    GoRoute(path: '/kenali/result', builder: (_, __) => const HasilKenaliDiriPage()),
    GoRoute(path: '/kenali', builder: (_, __) => const KenaliDiriHomePage()),
    GoRoute(path: '/kenali/history', builder: (_, __) => const KenaliDiriHistoryPage()),
  ],
);
