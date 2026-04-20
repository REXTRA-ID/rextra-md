import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rextra_app/core/theme/app_colors.dart';
import 'package:rextra_app/core/theme/app_typography.dart';

class PersonaInfoDetailPage extends StatefulWidget {
  const PersonaInfoDetailPage({super.key});
  @override
  State<PersonaInfoDetailPage> createState() => _PersonaInfoDetailPageState();
}

class _PersonaInfoDetailPageState extends State<PersonaInfoDetailPage> {
  bool showHowItWorks = true;

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
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          onPressed: () => _popOrGo(context, '/persona/welcome'),
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
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: 1.sw,
            height: 150.h,
            padding: EdgeInsets.only(top: 31.h, left: 27.w),
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/persona-detail-bg.png'),
              fit: BoxFit.cover,
            )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERSONA REXTRA',
                  style: AppTypography.h4.copyWith(color: Colors.white),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  'Persiapkan Karier Impian\nMulai Dari Sekarang!',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Tentang Fitur'),
                SizedBox(height: 8.h),
                Text(
                  'Persona REXTRA membantu kamu menggunakan aplikasi dengan cara yang paling sesuai dengan kondisi dan kebutuhanmu dalam mempersiapkan karier digital di perkuliahan.',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 24.h),
                _sectionTitle('Cara Kerja Fitur'),
                SizedBox(height: 8.h),
                Text(
                  'Kamu akan menjawab beberapa pertanyaan singkat yang membantu kami menentukan persona yang paling sesuai.',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 24.h),
                _sectionTitle('Penjelasan Persona'),
                SizedBox(height: 8.h),
                Text(
                  'REXTRA memiliki tiga persona utama yang mewakili kondisi persiapan karier mahasiswa.',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20.h),
                _personaCard(
                  asset: 'assets/images/rexpathfinder.png',
                  title: 'The Pathfinder',
                  desc:
                      'Mahasiswa yang saat ini sedang merencanakan langkah awal karier impian setelah lulus.',
                ),
                SizedBox(height: 20.h),
                _personaCard(
                  asset: 'assets/images/rexbuilder.png',
                  title: 'The Builder',
                  desc:
                      'Mahasiswa yang sudah memiliki rencana karir dan sedang berproses membangun portofolio.',
                ),
                SizedBox(height: 20.h),
                _personaCard(
                  asset: 'assets/images/rexachiever.png',
                  title: 'The Achiever',
                  desc:
                      'Mahasiswa yang siap mengikuti seleksi rekrutmen kerja dan memulai perjalanan karier pertama.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: AppTypography.h6.copyWith(fontWeight: FontWeight.w900)
      );

  Widget _personaCard({
    required String asset,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.CACACA,
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72.w,
            height: 90.h,
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                asset,
                width: 60.w,
                height: 78.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(desc, style: AppTypography.bodyXSmall, textAlign: TextAlign.justify,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
