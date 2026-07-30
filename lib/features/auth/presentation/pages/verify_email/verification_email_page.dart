import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_frontend/features/news/presentation/pages/daily_setup_screen.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
import '../auth_login_page.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start checking every 3 seconds automatically
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      context.read<AuthCubit>().checkVerificationStatus(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // 🚀 UPDATED: Uses AuthAuthenticated from our new app
          if (state is AuthAuthenticated) {
            _timer?.cancel();
            _showSuccessDialog(context);
          }
          // 🚀 UPDATED: Uses AuthError from our new app
          else if (state is AuthError) {
            if (!state.message.toLowerCase().contains("not verified")) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          } else if (state is Unauthenticated) {
            _timer?.cancel();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // // --- 🚀 THE "SOUL": WATERMARKS ---
              // Positioned(
              //   top: -50,
              //   right: -90,
              //   child: Icon(
              //     Icons.account_tree_outlined,
              //     size: 400,
              //     color: AppColors.primary.withOpacity(0.05),
              //   ),
              // ).animate().fade(duration: 1000.ms, curve: Curves.easeIn),

              // Positioned(
              //       bottom: -60,
              //       left: -80,
              //       child: Icon(
              //         Icons.headset_rounded,
              //         size: 380,
              //         color: AppColors.primary.withOpacity(0.04),
              //       ),
              //     )
              //     .animate(delay: 200.ms)
              //     .fade(duration: 1000.ms, curve: Curves.easeIn),

              // --- MAIN CONTENT ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ).animate().scale(
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Verify your email',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ).animate(delay: 100.ms).fade().slideY(begin: 0.1),

                    const SizedBox(height: 10),

                    const Text(
                      'We have sent a verification link to your email address.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ).animate(delay: 200.ms).fade().slideY(begin: 0.1),

                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Please check your spam folder if you do not see the email.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 300.ms).fade().slideY(begin: 0.1),

                    const SizedBox(height: 40),

                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey,
                      ),
                    ).animate(delay: 400.ms).fade(),

                    const SizedBox(height: 10),

                    const Text(
                      'Waiting for verification...',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ).animate(delay: 400.ms).fade(),

                    const SizedBox(height: 40),

                    TextButton(
                      onPressed: () {
                        context.read<AuthCubit>().resendVerificationEmail();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification link resent!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: const Text(
                        'Resend Link',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ).animate(delay: 500.ms).fade(),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () =>
                          context.read<AuthCubit>().cancelRegistration(),
                      child: const Text(
                        'Cancel Registration',
                        style: TextStyle(color: Colors.red),
                      ),
                    ).animate(delay: 600.ms).fade(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified,
              color: Colors.green,
              size: 80,
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            const Text(
              'Email Verified!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your account is now active and ready to use.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: "Let's Go",
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(ctx);
                // 🚀 UPDATED: Navigates to DailySetupScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const DailySetupScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
