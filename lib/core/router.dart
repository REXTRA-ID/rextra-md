import 'package:go_router/go_router.dart';
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
  ],
);
