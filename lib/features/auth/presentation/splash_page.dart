import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  Timer? _splashTimer;
  late final AnimationController _fillController;

  @override
  void initState() {
    super.initState();

    // Animasi "isi" logo naik dari bawah ke atas, menandakan loading.
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    // Pastikan navigasi dilakukan setelah frame pertama ter-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _splashTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        context.go('/onboarding');
      });
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0F5EEA), Color(0xFF1AB0FF)],
          ),
        ),
        child: Stack(
          children: [
            // VECTOR ATAS
            Positioned(
              top: -size.height * 0.04,
              left: -size.width * 0.10,
              child: Opacity(
                opacity: 0.22, // ditingkatkan biar jelas
                child: Image.asset(
                  'assets/images/vector1.png',
                  width: size.width * 0.95,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // VECTOR BAWAH
            Positioned(
              right: -size.width * 0.05,
              bottom: -size.height * 0.02,
              child: Opacity(
                opacity: 0.22,
                child: Image.asset(
                  'assets/images/vector2.png',
                  width: size.width * 0.92,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // LOGO (garis swirl saja, tanpa kartu putih & teks), dengan
            // efek "isi naik dari bawah ke atas" menandakan loading.
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Siluet garis logo redup, selalu terlihat penuh
                    Opacity(
                      opacity: 0.28,
                      child: Image.asset(
                        'assets/images/logo_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Garis logo terang yang "naik" mengisi dari bawah ke atas
                    AnimatedBuilder(
                      animation: _fillController,
                      builder: (context, child) {
                        return ClipRect(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            heightFactor: _fillController.value,
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/logo_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
