// lib/router/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rextra_app/features/home/presentation/home_page.dart';

// AUTH
import '../features/auth/presentation/forgot_password_pages.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/onboarding_pager.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/auth/presentation/verify_email_page.dart';

// PERSONA (Flow 2)
import '../features/kenalidiri/presentation/kenalidiri_pages.dart';
import '../features/persona/presentation/persona_pages.dart';

final router = GoRouter(
  initialLocation: '/splash',
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
      builder: (_, s) =>
          ForgotPasswordSentPage(email: s.uri.queryParameters['email'] ?? ''),
    ),
    GoRoute(
      path: '/forgot/expired',
      builder: (_, s) =>
          ForgotPasswordExpiredPage(email: s.uri.queryParameters['email'] ?? ''),
    ),
    GoRoute(
      path: '/forgot/new',
      builder: (_, s) =>
          NewPasswordPage(token: s.uri.queryParameters['token'] ?? ''),
    ),
    GoRoute(path: '/forgot/success', builder: (_, __) => const PasswordResetSuccessPage()),

    // --- Persona (Flow 2) ---
    GoRoute(path: '/persona/welcome', builder: (_, __) => const PersonaWelcomePage()),
    GoRoute(path: '/persona/info', builder: (_, __) => const PersonaInfoDetailPage()),

    GoRoute(
      path: '/persona/step1',
      builder: (_, __) => const PersonaStepPage(
        step: 1,
        title: 'Tujuan Karier',
        bannerAsset: 'assets/images/tujuan.png',
        optYes: 'Iya, saya sudah punya',
        optNo: 'Tidak, Saya belum punya',
      ),
    ),
    GoRoute(
      path: '/persona/step2',
      builder: (_, s) {
        final tujuan = (s.extra is Map && (s.extra as Map)['tujuan'] == true);
        return PersonaStepPage(
          step: 2,
          title: 'Portofolio Karier',
          bannerAsset: 'assets/images/porto.png',
          optYes: 'Iya, saya sedang membangun portofolio',
          optNo: 'Tidak, saya belum punya',
          sebelumnyaTujuan: tujuan,
        );
      },
    ),
    GoRoute(
      path: '/persona/step3',
      builder: (_, s) {
        final m = (s.extra is Map) ? s.extra as Map : {};
        return PersonaStepPage(
          step: 3,
          title: 'Rekrutmen Kerja',
          bannerAsset: 'assets/images/rekrutmen.png',
          optYes: 'Iya, saya sedang ikut',
          optNo: 'Tidak, saya belum ikut',
          sebelumnyaTujuan: m['tujuan'] == true,
          sebelumnyaPorto:  m['porto']  == true,
        );
      },
    ),
    GoRoute(
      path: '/persona/result',
      builder: (_, s) {
        final type = (s.extra is Map && (s.extra as Map)['type'] is PersonaType)
            ? (s.extra as Map)['type'] as PersonaType
            : PersonaType.pathfinder;
        return PersonaResultPage(type: type);
      },
    ),

    // --- Sementara: placeholder Home (agar /home tidak "not found") ---
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),
    GoRoute(path: '/kenali', builder: (_, __) => const KenaliDiriInfoPage()),
    GoRoute(path: '/kenali/riasec-intro', builder: (_, __) => const RiasecIntroPage()),
    GoRoute(path: '/kenali/ikigai-intro', builder: (_, __) => const IkigaiIntroPage()),
    GoRoute(path: '/kenali/riasec-test', builder: (_, __) => const RiasecTestPage()),
    GoRoute(path: '/kenali/ikigai-test', builder: (_, __) => const IkigaiTestPage()),
  ],
);