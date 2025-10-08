// lib/router/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// AUTH
import '../features/auth/presentation/forgot_password_pages.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/onboarding_pager.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/auth/presentation/verify_email_page.dart';

// PERSONA (Flow 2)
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
    GoRoute(path: '/home', builder: (_, __) => const _HomeTemporaryPage()),
  ],
);

/// ----------------- Placeholder Home -----------------
/// Ganti dengan halaman home sebenarnya nanti.
class _HomeTemporaryPage extends StatelessWidget {
  const _HomeTemporaryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/rextra.png', height: 22),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          AspectRatio(
            aspectRatio: 392 / 129,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/images/bgprofil.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Home (temporary)',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ini hanya placeholder agar rute /home tersedia. '
                'Silakan ganti ke halaman home sebenarnya ketika siap.',
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: () => context.push('/persona/welcome'),
            child: const Text('Mulai Persona REXTRA'),
          ),
        ],
      ),
    );
  }
}
