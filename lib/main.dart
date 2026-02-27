import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/router.dart'; // pastikan router kamu membaca provider auth/isLoggedIn
import 'core/storage/secure_storage.dart';
import 'core/network/api_client.dart'; // hanya untuk set header awal

// Jika support Web, aktifkan setelah `flutterfire configure`
// import 'firebase_options.dart';

/// Provider sederhana buat status login awal (dibaca router/guard).
final authBootstrapProvider = FutureProvider<bool>((ref) async {
  final token = await AppSecureStorage.readToken();
  // set ke ApiClient header global biar semua request langsung pakai token
  if (token != null && token.isNotEmpty) {
    ApiClient.attachBearer(token);
    return true;
  }
  return false;
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.enableDebugSSLBypass();
  if (kIsWeb) setUrlStrategy(PathUrlStrategy());

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase init (web pakai options)
  if (kIsWeb) {
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp();
  }

  runZonedGuarded(
        () => runApp(const ProviderScope(child: RextraApp())),
        (e, st) => debugPrint('Uncaught error: $e\n$st'),
  );
}

class RextraApp extends ConsumerWidget {
  const RextraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boot = ref.watch(authBootstrapProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'REXTRA',
      routerConfig: router, // router sebaiknya cek authBootstrapProvider di redirect
      scrollBehavior: const _NoGlowScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E6BFF),
          primary: const Color(0xFF2E6BFF),
          secondary: const Color(0xFF102542),
          background: Colors.white,
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
            backgroundColor: const Color(0xFF2E6BFF),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEAF1FF),
            foregroundColor: const Color(0xFF2E6BFF),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F9FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: Color(0xFF9AA5B1)),
        ),
      ),

      // Opsi: kamu bisa kasih splash ringan saat boot masih loading.
      // Tapi router redirect juga bisa baca FutureProvider ini.
      // builder: (context, child) => boot.when(
      //   data: (_) => child!,
      //   loading: () => const ColoredBox(color: Colors.white, child: Center(child: CircularProgressIndicator())),
      //   error: (_, __) => child!,
      // ),
    );
  }
}

class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
