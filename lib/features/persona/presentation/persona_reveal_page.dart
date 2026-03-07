import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rextra_app/core/theme/app_colors.dart';
import 'package:rextra_app/features/persona/domain/persona_models.dart';
import 'package:rextra_app/features/persona/presentation/providers/persona_provider.dart';

import '../../../../core/theme/app_typography.dart';

class PersonaRevealPage extends ConsumerStatefulWidget {
  const PersonaRevealPage({super.key});

  @override
  ConsumerState<PersonaRevealPage> createState() => _PersonaRevealPageState();
}

// Gunakan TickerProviderStateMixin karena kita punya lebih dari 1 AnimationController
class _PersonaRevealPageState extends ConsumerState<PersonaRevealPage>
    with TickerProviderStateMixin {
  // Controller untuk animasi muncul dari bawah
  late AnimationController _introController;
  late Animation<Offset> _slideAnimation;

  // Controller untuk animasi Flip & Miring (Tilt)
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late Animation<double> _tiltAnimation;

  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();

    // 1. Setup Animasi Intro (Slide Up)
    _introController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );

    // 2. Setup Animasi Flip & Tilt
    _flipController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _tiltAnimation =
        Tween<double>(begin: 2 * pi / 180, end: -2 * pi / 180).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    // Jalankan animasi intro otomatis saat halaman dirender
    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _onCardTap() {
    if (_isFlipped) return; // Mencegah animasi terpicu berkali-kali
    _flipController.forward();
    setState(() => _isFlipped = true);
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data hasil dari logic sebelumnya
    final personaState = ref.watch(personaProvider);
    final resultType = personaState.finalPersona ?? PersonaType.pathfinder;

    void _popOrGo(BuildContext context, String fallbackPath) {
      if (GoRouter.of(context).canPop()) {
        context.pop();
      } else {
        context.go(fallbackPath);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          onPressed: () => _popOrGo(context, '/persona/quistionnaire'),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.blueTop,
              AppColors.blueBottom,
            ],
          ).createShader(bounds),
          child: Text(
            'PERSONA REXTRA',
            style: AppTypography.h5.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. LAYER BACKGROUND FULL
          Positioned.fill(
            child: Image.asset(
              'assets/images/persona-reveal-bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. LAYER KARTU ANIMASI
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animasi Muncul dari Bawah (Slide)
                  SlideTransition(
                    position: _slideAnimation,
                    child: GestureDetector(
                      onTap: _onCardTap,
                      child: AnimatedBuilder(
                        animation: _flipController,
                        builder: (context, child) {
                          final flipAngle = _flipAnimation.value *
                              pi; // Rotasi Y 0 -> 180 deg
                          final tiltAngle =
                              _tiltAnimation.value; // Rotasi Z -2 -> 2 deg

                          // Deteksi kapan kartu harus berganti wujud (saat diputar setengah jalan)
                          final isFrontVisible = flipAngle < (pi / 2);

                          // Efek Perspektif 3D
                          final matrix = Matrix4.identity()
                            ..setEntry(3, 2, 0.0015)
                            ..rotateY(flipAngle);

                          return Transform.rotate(
                            angle: tiltAngle, // Eksekusi kemiringan
                            child: Transform(
                              transform: matrix, // Eksekusi putaran (Flip)
                              alignment: Alignment.center,
                              child: isFrontVisible
                                  ? _buildFrontCardPlaceholder()
                                  : Transform(
                                      // Membalik konten belakang agar tidak terbalik seperti cermin (mirror)
                                      transform: Matrix4.identity()
                                        ..rotateY(pi),
                                      alignment: Alignment.center,
                                      child:
                                          _buildBackCardPlaceholder(resultType),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // 3. LAYER TOMBOL LANJUTKAN (Akan muncul setelah animasi flip selesai)
                  // AnimatedOpacity(
                  //   opacity: _isFlipped ? 1.0 : 0.0,
                  //   duration: const Duration(milliseconds: 600),
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: 40.w),
                  //     child: ElevatedButton(
                  //       // Navigasi ke halaman detail persona
                  //       onPressed: _isFlipped
                  //           ? () => context.push('/persona/result')
                  //           : null,
                  //       child: const Text('Lanjutkan'),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // AREA KERJA KAMU: ISI DESAIN KARTU DI SINI
  // ==========================================

  Widget _buildFrontCardPlaceholder() {
    return Container(
      width: 331.w,
      height: 557.h,
      padding: EdgeInsets.symmetric(horizontal: 35.w),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF090B72),
              Color(0xFF064ADF),
              Color(0xFF23DCE1),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 16, offset: Offset(0, 10)),
          ],
          image: const DecorationImage(
            image: AssetImage('assets/images/persona-front-card-bg.png'),
            fit: BoxFit.cover,
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 44.37.h),
          Container(
            width: 81.31.w,
            height: 81.31.h,
            padding:
                EdgeInsets.symmetric(vertical: 15.89.h, horizontal: 21.67.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.79.r),
              color: const Color(0xFFFAFAFA),
            ),
            child: Center(
              child: Image.asset('assets/images/reveal-question-ic.png'),
            ),
          ),
          SizedBox(height: 19.37.h),
          Text(
            'Sentuh Kartu untuk Melihat Persona Rextra Milikmu!',
            style: AppTypography.h4.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBackCardPlaceholder(PersonaType type) {
    return Container(
      // width: 310.w,
      // height: 480.h,
      // decoration: BoxDecoration(
      //   color: const Color(0xFF2E6BFF), // Ganti dengan gambar asset hasil persona
      //   borderRadius: BorderRadius.circular(24.r),
      //   boxShadow: const [
      //     BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 10)),
      //   ],
      // ),
      // child: Center(
      //   child: Text(
      //     'CARD BELAKANG\n\nHasil: ${type.name.toUpperCase()}\n\n(Isi desain hasil di sini)',
      //     textAlign: TextAlign.center,
      //     style: TextStyle(color: Colors.white, fontSize: 18.sp),
      //   ),
      // ),
      width: 331.w,
      // height: 557.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 30.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFF9BD8FE),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 16, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Taraa! Persona Kamu adalah:',
            style: AppTypography.h6,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          // make image with if else from persona type
          Image.asset(
            type == PersonaType.pathfinder
                ? 'assets/images/reveal-mascot-pathfinder.png'
                : type == PersonaType.achiever
                    ? 'assets/images/reveal-mascot-achiever.png'
                    : 'assets/images/reveal-mascot-builder.png',
            width: 237.w,
            height: 200.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 24.h),
          //   border radius container with row as child
          Container(
            width: 290.w,
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              // linear color gradient from top to bottom with 2 color
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0057FF),
                  Color(0xFF23DBE0),
                ],
              ),
              borderRadius: BorderRadius.circular(900.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/reveal-star-ic.png',
                  width: 20.w,
                  height: 20.h,
                ),
                SizedBox(width: 8.w),
                //   if else text with persona type
                Text(
                  'The ${type == PersonaType.pathfinder ? 'Pathfinder' : type == PersonaType.achiever ? 'Achiever' : 'Builder'}'
                      .toUpperCase(),
                  // uppercase
                  style: AppTypography.h4.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 8.w),
                Image.asset(
                  'assets/images/reveal-star-ic.png',
                  width: 20.w,
                  height: 20.h,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          //   if else text with persona type and description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Text(
              type == PersonaType.pathfinder
                  ? 'Sebagai Pathfinder, kamu sedang dalam proses mencari dan merencanakan karier digital impian.'
                  : type == PersonaType.achiever
                      ? 'Sebagai Achiever, kamu semakin dekat dengan karier impian! Di tahap ini, kamu sudah siap menghadapi proses seleksi kerja atau magang. '
                      : 'Sebagai Builder, kamu akan mulai membangun fondasi karier dengan membuat portofolio profesional.',
              style: AppTypography.bodyXSmall.copyWith(
                  color: AppColors.black900, fontWeight: FontWeight.w400),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(height: 15.h,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: ElevatedButton(
              // onPressed: _isFlipped
              //     ? () => context.push('/persona/result')
              //     : null,
              onPressed: () {},
              child: const Text('Lanjutkan'),
            ),
          ),
        ],
      ),
    );
  }
}
