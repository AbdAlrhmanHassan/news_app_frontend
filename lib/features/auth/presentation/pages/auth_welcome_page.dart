import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_frontend/core/widgets/custom_button.dart';
import 'package:news_app_frontend/features/auth/presentation/pages/auth_login_page.dart';
import 'package:news_app_frontend/features/auth/presentation/pages/auth_register_page.dart';
import 'package:news_app_frontend/features/auth/presentation/widgets/social_login_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../news/presentation/pages/daily_setup_screen.dart';

import '../../../news/presentation/pages/main_feed_screen.dart'; // Ensure this exists or use DailyMixPlayerScreen
import '../../../user/presentation/cubit/user_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AuthWelcomePage extends StatelessWidget {
  const AuthWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    const duration = Duration(milliseconds: 600);
    const curve = Curves.easeOutCubic;
    const slideBegin = 0.05;

    final Widget appleButton = SocialAuthButton(
      text: 'Continue with Apple',
      iconPath: 'assets/icons/Apple_logo.svg',
      borderColor: AppColors.primary.withOpacity(0.8),
      onTap: () {
        context.read<AuthCubit>().signInWithApple();
      },
    );

    final Widget googleButton = SocialAuthButton(
      text: 'Continue with Google',
      borderColor: AppColors.primary.withOpacity(0.8),
      iconPath: 'assets/icons/Google.svg',
      onTap: () {
        context.read<AuthCubit>().signInWithGoogle();
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: MultiBlocListener(
          listeners: [
            // --- 🎧 LISTENER 1: WAITS FOR AUTHENTICATION ---
            BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } else if (state is AuthAuthenticated) {
                  // 1. Auth is successful! Now, tell UserCubit to fetch the data.
                  context.read<UserCubit>().getUserData(uid: state.user.id);
                }
              },
            ),

            // --- 🎧 LISTENER 2: WAITS FOR FIRESTORE DATA ---
            BlocListener<UserCubit, UserState>(
              listener: (context, state) {
                if (state is UserLoaded) {
                  // 2. The data has officially arrived from Firebase!
                  final user = state.user;
                  // 3. NOW it is 100% safe to check the routine and navigate.
                  if (user.dailyRoutine.isNotEmpty) {
                    // 🎵 Returning user: Straight to the Player!
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyMixPlayerScreen(
                          languageCode: 'en',
                          orderedCategoryIds: List<String>.from(
                            user.dailyRoutine,
                          ),
                        ),
                      ),
                    );
                  } else {
                    // ⚙️ New user or Guest: Straight to the Setup screen!
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailySetupScreen(),
                      ),
                    );
                  }
                } else if (state is UserError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
            ),
          ],

          // 🚀 THE FIX: We use 'child' here, and wrap the UI in a BlocBuilder!
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return Stack(
                children: [
                  // --- TOP RIGHT WATERMARK ---
                  Positioned(
                    top: -50,
                    right: -90,
                    child: Icon(
                      Icons.account_tree_outlined,
                      size: 400,
                      color: AppColors.primary.withOpacity(0.08),
                    ),
                  ).animate().fade(duration: 1000.ms, curve: Curves.easeIn),

                  // --- BOTTOM LEFT WATERMARK ---
                  Positioned(
                        bottom: -60,
                        left: -80,
                        child: Icon(
                          Icons.headset_rounded,
                          size: 380,
                          color: AppColors.primary.withOpacity(0.06),
                        ),
                      )
                      .animate(delay: 200.ms)
                      .fade(duration: 1000.ms, curve: Curves.easeIn),

                  SafeArea(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- BLOCK 1: HEADER ---
                                Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 36),
                                        Text(
                                          'Save your\ndaily mix.',
                                          style: TextStyle(
                                            color: AppColors.textDark
                                                .withOpacity(0.95),
                                            fontSize: 48,
                                            fontWeight: FontWeight.w900,
                                            height: 1.05,
                                            letterSpacing: -1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Create an account to sync your customized news routine across all your devices.',
                                          style: TextStyle(
                                            color: AppColors.textGrey
                                                .withOpacity(0.85),
                                            fontSize: 16,
                                            height: 1.5,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    )
                                    .animate()
                                    .fade(duration: duration, curve: curve)
                                    .slideY(begin: slideBegin, curve: curve),

                                const Spacer(),

                                // --- BLOCK 2: SOCIAL BUTTONS ---
                                Column(
                                      children: [
                                        if (isIOS) ...[
                                          appleButton,
                                          const SizedBox(height: 16),
                                          googleButton,
                                        ] else ...[
                                          googleButton,
                                          const SizedBox(height: 16),
                                          appleButton,
                                        ],
                                      ],
                                    )
                                    .animate(delay: 150.ms)
                                    .fade(duration: duration, curve: curve)
                                    .slideY(begin: slideBegin, curve: curve),

                                const SizedBox(height: 28),

                                // --- BLOCK 3: DIVIDER & EMAIL BUTTONS ---
                                Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Divider(
                                                color: AppColors.textGrey
                                                    .withOpacity(0.15),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                  ),
                                              child: Text(
                                                'Or continue with',
                                                style: TextStyle(
                                                  color: AppColors.textGrey
                                                      .withOpacity(0.6),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: AppColors.textGrey
                                                    .withOpacity(0.15),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 28),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomButton(
                                                text: 'Login',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginPage(),
                                                    ),
                                                  );
                                                },
                                                hasShadow: true,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: CustomButton(
                                                text: 'Register',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const RegisterPage(),
                                                    ),
                                                  );
                                                },
                                                backgroundColor: Colors.white,
                                                borderColor: AppColors.primary
                                                    .withOpacity(0.3),
                                                hasShadow: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                    .animate(delay: 300.ms)
                                    .fade(duration: duration, curve: curve)
                                    .slideY(begin: slideBegin, curve: curve),

                                const Spacer(),

                                // --- BLOCK 4: GUEST BUTTON ---
                                Center(
                                      child: TextButton(
                                        onPressed: () {
                                          context
                                              .read<AuthCubit>()
                                              .signInAsGuest();
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.textGrey
                                              .withOpacity(0.9),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Continue as a guest',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 16,
                                              color: AppColors.textGrey
                                                  .withOpacity(0.7),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .animate(delay: 450.ms)
                                    .fade(duration: duration, curve: curve)
                                    .slideY(begin: slideBegin, curve: curve),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🚀 LOADING OVERLAY (Safely checks the AuthState!)
                  if (state is AuthLoading)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          color: Colors.black.withOpacity(0.2),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
