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
    final topHeight = size.height * 0.55;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              return Column(
                children: [
                  SizedBox(
                    height: topHeight,
                    width: double.infinity,
                    child: SafeArea(
                      bottom: false,
                      child: Image.asset(
                        _images[i],
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, -6),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _titles[i],
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _subtitles[i],
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 18),
                              _Dots(current: _index, total: _images.length),
                              const Spacer(),
                              // Tombol: langsung skip ke verifikasi
                              ElevatedButton(
                                onPressed: () {
                                  context.go('/verify?mode=sent&email=test@rextra.com');
                                },
                                child: const Text('Masuk Aplikasi'),
                              ),
                              const SizedBox(height: 10),
                              FilledButton(
                                onPressed: () {
                                  context.go('/verify?mode=sent&email=test@rextra.com');
                                },
                                child: const Text('Daftar Akun'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
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
