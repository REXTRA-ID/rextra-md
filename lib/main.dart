import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rextra_app/core/theme/app_colors.dart';
import 'package:rextra_app/core/theme/app_typography.dart';

import 'core/router.dart';
import 'core/storage/secure_storage.dart';
import 'core/network/api_client.dart';

final authBootstrapProvider = FutureProvider<bool>((ref) async {
  final token = await AppSecureStorage.readToken();
  if (token != null && token.isNotEmpty) {
    ApiClient.attachBearer(token);
    return true;
  }
  return false;
});

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    ApiClient.enableDebugSSLBypass();
    if (kIsWeb) setUrlStrategy(PathUrlStrategy());

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    await Firebase.initializeApp();
    runApp(
      const ProviderScope(
        child: RextraApp(),
      ),
    );
  }, (e, st) {
    debugPrint('Uncaught error: $e\n$st');
  });
}

class RextraApp extends ConsumerWidget {
  const RextraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authBootstrapProvider);

    return ScreenUtilInit(
      designSize: const Size(393, 852), 
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'REXTRA',
          routerConfig: router,
          scrollBehavior: const _NoGlowScrollBehavior(),
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2E6BFF),
              primary: const Color(0xFF2E6BFF),
              secondary: const Color(0xFF102542),
              surface: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF102542)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 52.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                textStyle: AppTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary100,
                foregroundColor: AppColors.primary600,
                minimumSize: Size(double.infinity, 52.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                textStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primary600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}