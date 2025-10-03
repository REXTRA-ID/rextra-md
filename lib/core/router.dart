// lib/router/app_router.dart
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/forgot_password_pages.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/auth/presentation/onboarding_pager.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/auth/presentation/verify_email_page.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPager()),
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(
      path: '/verify',
      builder: (ctx, s) => VerifyEmailPage(
        email: s.uri.queryParameters['email'] ?? '',
        mode: s.uri.queryParameters['mode'] ?? 'sent', // sent|resent|expired
      ),
    ),

    // Forgot password flow
    GoRoute(
      path: '/forgot',
      builder: (context, state) => const ForgotPasswordRequestPage(),
    ),
    GoRoute(
      path: '/forgot/sent',
      builder: (context, state) =>
          ForgotPasswordSentPage(email: state.uri.queryParameters['email'] ?? ''),
    ),
    GoRoute(
      path: '/forgot/expired',
      builder: (context, state) =>
          ForgotPasswordExpiredPage(email: state.uri.queryParameters['email'] ?? ''),
    ),
    GoRoute(
      path: '/forgot/new',
      builder: (context, state) =>
          NewPasswordPage(token: state.uri.queryParameters['token'] ?? ''),
    ),
    GoRoute(
      path: '/forgot/success',
      builder: (context, state) => const PasswordResetSuccessPage(),
    ),
  ],
);
