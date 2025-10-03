import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Pastikan navigasi dilakukan setelah frame pertama ter-render
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      context.go('/onboarding');
    });
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
            // LOGO TANPA FRAME PUTIH
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 124,
                height: 124,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
