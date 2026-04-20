import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rextra_app/core/theme/app_colors.dart';
import 'package:rextra_app/core/theme/app_typography.dart';

class PersonaWelcomePage extends StatelessWidget {
  const PersonaWelcomePage({super.key});

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
          onPressed: () => _popOrGo(context, '/login'),
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
          // LAYER 1: BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/images/persona-welcome-bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // LAYER 2: KONTEN
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
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/persona-welcome-logo.png',
                                width: 104.25.w,
                                height: 103.05.h,
                                fit: BoxFit.contain,
                              ),
                              Text('Selamat Datang,', style: AppTypography.h5.copyWith(color: Colors.white), textAlign: TextAlign.center,),
                              Text('Sobat REXTRA!', style: AppTypography.h3.copyWith(color: Colors.white), textAlign: TextAlign.center),
                            ],
                          ),
                          Image.asset(
                            'assets/images/persona-welcome-mascot.png',
                            width: 239.w,
                            height: 269.h,
                            fit: BoxFit.contain,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Kenalin, aku Rexi 👋',
                                textAlign: TextAlign.center,
                                style: AppTypography.h4,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Asisten virtual yang siap menemani\nperjalanan kariermu ✨ Yuk, mulai langkah\npertama menuju karier impianmu!',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => context.push('/persona/intro'),
                            child: const Text(
                              'Lanjutkan',
                            ),
                          ),
                          SizedBox(height: 16.h),
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