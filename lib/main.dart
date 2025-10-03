import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/router.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const ProviderScope(child: RextraApp()));
}

class RextraApp extends StatelessWidget {
  const RextraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'REXTRA',
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
      routerConfig: router,
    );
  }
}
