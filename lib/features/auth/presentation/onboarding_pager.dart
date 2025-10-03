import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPager extends StatefulWidget {
  const OnboardingPager({super.key});
  @override
  State<OnboardingPager> createState() => _OnboardingPagerState();
}

class _OnboardingPagerState extends State<OnboardingPager> {
  final _controller = PageController();
  int _index = 0;

  final _images = const [
    'assets/images/background1.png',
    'assets/images/background3.png',
    'assets/images/background2.png',
  ];

  final _titles = const [
    'Buat Rencana Karier Yang\nMudah dan Praktis',
    'Tingkatkan Peluang Lolos\nSeleksi Rekrutmen Kerja',
    'Catat Kegiatan Pendukung\nCapaian Karir Digital',
  ];

  final _subtitles = const [
    'Rencanakan tujuan karir kamu dengan lebih jelas dan terarah menggunakan teknologi AI dari REXTRA yang terpersonalisasi.',
    'Persiapkan CV terbaik, latihan interview, dan mentoring dari para expert untuk meningkatkan peluang lolos seleksi.',
    'Catat semua kegiatan yang mendukung tujuan karir kamu dan dapatkan rekomendasi kegiatan yang relevan.',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _controller,
        itemCount: _images.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) {
          return Stack(
            children: [
              // ===== background putih full =====
              Container(color: Colors.white),

              // ===== gambar biru ditimpa di atas =====
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  _images[i],
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                ),
              ),

              // ===== panel konten (full putih, tanpa border radius) =====
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
                  color: Colors
                      .white, // full putih, gak pake borderRadius biar "nyambung" ke atas
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _titles[i],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                          color: Color(0xFF2E6BFF), // biru
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _subtitles[i],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600, // bold tipis
                          height: 1.5,
                          color: Color(0xFF2E3A4C),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Dots(current: _index, total: _images.length),
                      const SizedBox(height: 30),

                      // Tombol Masuk
                      ElevatedButton(
                        onPressed: () => context.push('/login'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Masuk Aplikasi'),
                      ),
                      const SizedBox(height: 12),

                      // Tombol Daftar
                      FilledButton(
                        onPressed: () => context.push('/register'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Daftar Akun'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int current, total;
  const _Dots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2E6BFF) : const Color(0xFFCFE0FF),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
