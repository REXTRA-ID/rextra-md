import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_typography.dart';

class PersonaIntroPage extends StatelessWidget {
  const PersonaIntroPage({super.key});

  void _popOrGo(BuildContext context, String fallbackPath) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go(fallbackPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _popOrGo(context, '/persona/welcome'),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Image.asset('assets/images/rextra.png', height: 22.h),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: Stack(
        children: [
          // 1. LAYER BACKGROUND BAWAH
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/persona-info-bg.png', // Pastikan nama aset sudah benar
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),

          // 2. LAYER KONTEN UTAMA (Teks & Tombol)
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Teks rata kiri
                        children: [
                          SizedBox(height: 32.h), // Jarak dari AppBar

                          Text(
                            'Sebelum Itu, Rexi Ingin Mengenal Diri Kamu',
                            style: AppTypography.h4
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Eitss, jangan baper! 😉 Rexi cuma perlu memahami kebutuhan kariermu saat ini kok. Yuk, isi Tes Persona REXTRA biar Rexi bisa kasih panduan fitur yang lebih tepat',
                            style: AppTypography.bodySmall,
                          ),
                          SizedBox(height: 35.h),
                          ElevatedButton(
                            onPressed: () => context.push('/persona/quistionnaire'),
                            child: const Text('Mulai Tes Persona Karier'),
                          ),
                          SizedBox(height: 10.h),
                          FilledButton(
                            onPressed: () => context.push('/persona/info'),
                            child: const Text('Tentang Persona Karier'),
                          ),
                          SizedBox(height: 350.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}