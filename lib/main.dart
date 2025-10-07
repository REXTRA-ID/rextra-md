// lib/main.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/router.dart';
// Jika kamu mendukung Web, generate file ini:
// import 'firebase_options.dart'; // <- hasil `flutterfire configure`

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hilangkan # di URL hanya saat web
  if (kIsWeb) setUrlStrategy(PathUrlStrategy());

  // Kunci orientasi (opsional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inisialisasi Firebase (wajib untuk Google Sign-In)
  if (kIsWeb) {
    // TODO: jika support web, uncomment baris di bawah ini setelah generate firebase_options.dart
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else {
    await Firebase.initializeApp();
  }

  // Jalankan app dengan guard supaya error global tetap tercatat
  runZonedGuarded(
        () => runApp(const ProviderScope(child: RextraApp())),
        (e, st) => debugPrint('Uncaught error: $e\n$st'),
  );
}

class RextraApp extends StatelessWidget {
  const RextraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'REXTRA',
      routerConfig: router,
      scrollBehavior: const _NoGlowScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,

        // 🎨 Warna utama REXTRA
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E6BFF), // biru khas REXTRA
          primary: const Color(0xFF2E6BFF),
          secondary: const Color(0xFF102542),
          background: Colors.white,
        ),

        scaffoldBackgroundColor: Colors.white,

        // AppBar default → putih dengan teks/logo biru
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF102542)),
        ),

        // Tombol utama
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

        // Tombol alternatif (FilledButton → style biru muda)
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
    );
  }
}

/// Menghilangkan efek glow saat scroll (Android & Web)
class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
