import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_frontend/features/news/presentation/pages/daily_setup_screen.dart';

import '../../../../core/constants/custom_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'auth_register_page.dart'; // 🚀 NEW: Import your register page
import 'forgot_password/forgot_password_page.dart';
import 'verify_email/verification_email_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 🚀 NEW: BlocConsumer to handle actual Auth states!
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DailySetupScreen()),
              (route) => false,
            );
          } else if (state is AuthVerificationNeeded) {
            // 🚀 FIX: If they try to log in (or reopen the app) without verifying,
            // send them straight to the VerificationPage!
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const VerificationPage()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // --- 🚀 THE "SOUL": TOP RIGHT WATERMARK ---
              Positioned(
                top: -50,
                right: -90,
                child: Icon(
                  Icons.account_tree_outlined,
                  size: 400,
                  color: AppColors.primary.withOpacity(0.05),
                ),
              ).animate().fade(duration: 1000.ms, curve: Curves.easeIn),

              // --- 🚀 THE "SOUL": BOTTOM LEFT WATERMARK ---
              Positioned(
                    bottom: -60,
                    left: -80,
                    child: Icon(
                      Icons.headset_rounded,
                      size: 380,
                      color: AppColors.primary.withOpacity(0.04),
                    ),
                  )
                  .animate(delay: 200.ms)
                  .fade(duration: 1000.ms, curve: Curves.easeIn),

              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _autovalidateMode,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              const Text(
                                'Welcome back!\nGlad to see you.',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight
                                      .w900, // Punchier weight to match Welcome screen
                                  color: Colors.black87,
                                  height: 1.1,
                                  letterSpacing: -1.0,
                                ),
                              ).animate().fade().slideY(
                                begin: 0.1,
                                duration: 400.ms,
                              ),

                              const SizedBox(height: 40),

                              CustomTextField(
                                controller: _emailCtrl,
                                hintText: 'Enter your email',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  final emailRegex = RegExp(
                                    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                                  );
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ).animate(delay: 100.ms).fade().slideY(begin: 0.1),

                              const SizedBox(height: 16),

                              CustomTextField(
                                controller: _passCtrl,
                                hintText: 'Enter your password',
                                isPassword: !_isPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(
                                    () => _isPasswordVisible =
                                        !_isPasswordVisible,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ).animate(delay: 200.ms).fade().slideY(begin: 0.1),

                              Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ForgotPasswordPage(
                                            userEmail: _emailCtrl.text,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .animate(delay: 300.ms)
                                  .fade()
                                  .slideY(begin: 0.1),

                              const SizedBox(height: 16),

                              // 🚀 NEW: Custom Button now uses Bloc State!
                              CustomButton(
                                text: 'Login',
                                backgroundColor: AppColors.primary,
                                textColor: Colors.white,
                                borderColor: Colors.transparent,
                                isLoading:
                                    state
                                        is AuthLoading, // Hooks directly to your custom button UI
                                onPressed: state is AuthLoading
                                    ? null
                                    : _submitLogin,
                              ).animate(delay: 400.ms).fade().slideY(begin: 0.1),

                              const SizedBox(height: 30),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Don\'t have an account? ',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // 🚀 UNCOMMENTED: Navigates to Register Page
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const RegisterPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Register Now',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate(delay: 500.ms).fade().slideY(begin: 0.1),

                              const SizedBox(height: 10),

                              Center(
                                    child: TextButton(
                                      onPressed: () {
                                        // 🚀 NEW: Triggers actual Guest Login!
                                        context
                                            .read<AuthCubit>()
                                            .signInAsGuest();
                                      },
                                      child: const Text(
                                        'Continue as Guest',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                  .animate(delay: 600.ms)
                                  .fade()
                                  .slideY(begin: 0.1),

                              const Spacer(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      // 🚀 NEW: Calls real Firebase Auth instead of a fake delay
      context.read<AuthCubit>().loginWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
    } else {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
    }
  }
}
