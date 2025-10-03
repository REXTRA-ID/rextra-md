import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/splash_page.dart';
import 'features/auth/presentation/onboarding_pager.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/auth/presentation/verify_email_page.dart';

void main() {
  runApp(const RextraApp());
}

class RextraApp extends StatelessWidget {
  const RextraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash',    builder: (_, __) => const SplashPage()),
        GoRoute(path: '/onboarding',builder: (_, __) => const OnboardingPager()),
        GoRoute(path: '/login',     builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register',  builder: (_, __) => const RegisterPage()),
        GoRoute(
          path: '/verify',
          builder: (context, state) {
            final mode  = state.uri.queryParameters['mode'] ?? 'default';
            final email = state.uri.queryParameters['email'] ?? '';
            return VerifyEmailPage(mode: mode, email: email);
          },
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'REXTRA',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E63F6)),

        // ⬇️ Hilangkan back default (biar gak ada panah hiasan)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          // NOTE: tidak ada automaticallyImplyLeading di AppBarTheme.
          // Kita akan set per-Page dengan leading manual + canPop().
        ),

        textTheme: const TextTheme(
          headlineLarge:  TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0E1B2B)),
          headlineMedium: TextStyle(fontSize: 22, height: 1.25, fontWeight: FontWeight.w800, color: Color(0xFF0E1B2B)),
          titleMedium:    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0E1B2B)),
          bodyMedium:     TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF44546A)),
          labelLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            backgroundColor: const Color(0xFF1E63F6),
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            backgroundColor: const Color(0xFFEAF1FF),
            foregroundColor: const Color(0xFF2E6BFF),
            elevation: 0,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E6F3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2E6BFF), width: 1.6),
          ),
        ),
      ),
    );
  }
}
