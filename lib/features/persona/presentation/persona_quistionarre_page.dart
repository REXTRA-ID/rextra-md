import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rextra_app/features/persona/presentation/providers/persona_provider.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/persona_models.dart';

class PersonaQuestionnairePage extends ConsumerStatefulWidget {
  const PersonaQuestionnairePage({super.key});

  @override
  ConsumerState<PersonaQuestionnairePage> createState() =>
      _PersonaQuestionnairePageState();
}

class _PersonaQuestionnairePageState
    extends ConsumerState<PersonaQuestionnairePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _ansQ1 = true;
  // 'iya' | 'sedang' | 'tidak'
  String _ansQ2 = 'iya';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _popOrGo(BuildContext context, String fallbackPath) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go(fallbackPath);
    }
  }

  void _nextStep() async {
    final notifier = ref.read(personaProvider.notifier);

    if (_currentPage == 0) {
      // IF Q1 == "Tidak" -> Pathfinder
      if (_ansQ1 == false) {
        await notifier.saveEarlyDecision(PersonaType.pathfinder);
        if (mounted) context.push('/persona/reveal');
        return;
      }
      // ELSE (Q1 == "Iya") -> Lanjut Q2
      notifier.setTujuan(true);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else if (_currentPage == 1) {
      // Q1 == "Iya" sudah pasti di sini.
      // IF Q2 == "Iya" -> Achiever, ELSE (Sedang/Tidak) -> Builder
      final type = _ansQ2 == 'iya' ? PersonaType.achiever : PersonaType.builder;
      await notifier.saveEarlyDecision(type);
      if (mounted) context.push('/persona/reveal');
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
          onPressed: () {
            if (_currentPage == 0) {
              _popOrGo(context, '/persona/info');
            } else {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
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
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildQuestionPage(
                  title: 'Tujuan Karier',
                  questionText: 'Apakah kamu sudah punya tujuan karier?',
                  selectedAns: _ansQ1,
                  optYes: 'Iya, saya sudah punya',
                  optNo: 'Tidak, Saya belum punya',
                  onChanged: (val) => setState(() => _ansQ1 = val),
                ),
                _buildQuestionPage3(
                  title: 'Portofolio Karier',
                  questionText:
                      'Lantas, apakah kamu sedang membangun portofolio profesional?',
                  selectedAns: _ansQ2,
                  options: const [
                    ('iya', 'Iya, saya sudah punya'),
                    ('sedang', 'Sedang saya bangun'),
                    ('tidak', 'Tidak, saya belum punya'),
                  ],
                  onChanged: (val) => setState(() => _ansQ2 = val),
                ),
              ],
            ),
          ),

          // BAGIAN BAWAH: Sticky Bottom Bar bergaya BottomSheet
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                24.w,
                16.h,
                24.w,
                MediaQuery.of(context).padding.bottom > 0
                    ? MediaQuery.of(context).padding.bottom + 8.h
                    : 24.h),
            decoration: BoxDecoration(
              color: Colors.white, // Background bar putih
              border: const Border(
                top: BorderSide(
                  color: Color(0xFFCACACA), // Garis border atas sesuai desain
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04), // Shadow tipis elegan
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _nextStep,
              child: const Text('Lanjutkan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage({
    required String title,
    required String questionText,
    required bool selectedAns,
    required String optYes,
    required String optNo,
    required Function(bool) onChanged,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 18.h),
            Text(title,
                style: AppTypography.h5.copyWith(color: AppColors.primary600)),
            SizedBox(height: 12.h),
            Container(
              width: 352.w,
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.06.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF090B72),
                    Color(0xFF064ADF),
                    Color(0xFF23DCE1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                image: const DecorationImage(
                  image:
                      AssetImage('assets/images/persona-quistionnare-bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    questionText, // <-- Masukkan variabel teks di sini
                    style: AppTypography.h5.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            _buildOptionTile(
              text: optYes,
              isSelected: selectedAns == true,
              onTap: () => onChanged(true),
            ),
            SizedBox(height: 28.h),
            _buildOptionTile(
              text: optNo,
              isSelected: selectedAns == false,
              onTap: () => onChanged(false),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage3({
    required String title,
    required String questionText,
    required String selectedAns,
    required List<(String value, String label)> options,
    required Function(String) onChanged,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 18.h),
            Text(title,
                style: AppTypography.h5.copyWith(color: AppColors.primary600)),
            SizedBox(height: 12.h),
            Container(
              width: 352.w,
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.06.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF090B72),
                    Color(0xFF064ADF),
                    Color(0xFF23DCE1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                image: const DecorationImage(
                  image:
                      AssetImage('assets/images/persona-quistionnare-bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    questionText,
                    style: AppTypography.h5.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            for (final (i, option) in options.indexed) ...[
              if (i > 0) SizedBox(height: 20.h),
              _buildOptionTile(
                text: option.$2,
                isSelected: selectedAns == option.$1,
                onTap: () => onChanged(option.$1),
              ),
            ],
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
      {required String text,
      required bool isSelected,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3ECFF) : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.primary600 : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(
            color: isSelected ? AppColors.primary600 : AppColors.black500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
