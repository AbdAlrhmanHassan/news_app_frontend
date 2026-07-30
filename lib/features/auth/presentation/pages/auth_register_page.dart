import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_frontend/features/news/presentation/pages/daily_setup_screen.dart';

import '../../../../core/constants/custom_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'auth_login_page.dart';
import 'verify_email/verification_email_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  String? _selectedCountry;

  final List<Map<String, String>> _countries = [
    {'name': 'Jordan', 'flag': '🇯🇴'},
    {'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'name': 'United Arab Emirates', 'flag': '🇦🇪'},
    {'name': 'Egypt', 'flag': '🇪🇬'},
    {'name': 'Qatar', 'flag': '🇶🇦'},
  ];

  final TextEditingController _regionCtrl = TextEditingController();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _regionCtrl.dispose();
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
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else if (state is AuthVerificationNeeded) {
            // 🚀 UPDATED: Navigate directly to VerificationPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const VerificationPage()),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Positioned(
                top: -50,
                right: -90,
                child: Icon(
                  Icons.account_tree_outlined,
                  size: 400,
                  color: AppColors.primary.withOpacity(0.05),
                ),
              ).animate().fade(duration: 1000.ms, curve: Curves.easeIn),

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
                                'Hello!\nRegister to get started.',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
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
                                    controller: _usernameCtrl,
                                    hintText: 'Username',
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Username is required'
                                        : null,
                                  )
                                  .animate(delay: 100.ms)
                                  .fade()
                                  .slideY(begin: 0.1),

                              CustomTextField(
                                controller: _emailCtrl,
                                hintText: 'Email',
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
                              ).animate(delay: 150.ms).fade().slideY(begin: 0.1),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: DropdownMenu<String>(
                                        initialSelection: _selectedCountry,
                                        expandedInsets: EdgeInsets.zero,
                                        menuHeight: 250,
                                        hintText: 'Country',
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF8391A1),
                                        ),
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                              filled: true,
                                              fillColor: const Color(
                                                0xFFF7F8F9,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 16,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: AppColors.primary
                                                      .withOpacity(0.35),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                        menuStyle: MenuStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                Colors.white,
                                              ),
                                          elevation: WidgetStateProperty.all(3),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                        onSelected: (String? newValue) {
                                          setState(() {
                                            _selectedCountry = newValue;
                                          });
                                        },
                                        dropdownMenuEntries: _countries.map((
                                          countryMap,
                                        ) {
                                          return DropdownMenuEntry<String>(
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  WidgetStateProperty.all(
                                                    Colors.black,
                                                  ),
                                            ),
                                            value: countryMap['name']!,
                                            label: countryMap['name']!,
                                            leadingIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                                right: 4.0,
                                              ),
                                              child: Text(
                                                countryMap['flag']!,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _regionCtrl,
                                      hintText: 'Region / State',
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Required'
                                          : null,
                                    ),
                                  ),
                                ],
                              ).animate(delay: 200.ms).fade().slideY(begin: 0.1),
                              CustomTextField(
                                controller: _passCtrl,
                                hintText: 'Password',
                                isPassword: true,
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Password must be at least 6 characters'
                                    : null,
                              ).animate(delay: 250.ms).fade().slideY(begin: 0.1),

                              CustomTextField(
                                    controller: _confirmPassCtrl,
                                    hintText: 'Confirm Password',
                                    isPassword: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passCtrl.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  )
                                  .animate(delay: 300.ms)
                                  .fade()
                                  .slideY(begin: 0.1),

                              const SizedBox(height: 20),

                              Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        const Text(
                                          'By signing up, you agree to our ',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: const Text(
                                            'Terms of Service',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          ' and ',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: const Text(
                                            'Privacy Policy',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate(delay: 350.ms)
                                  .fade()
                                  .slideY(begin: 0.1),

                              const SizedBox(height: 20),

                              CustomButton(
                                    text: 'Register',
                                    backgroundColor: AppColors.primary,
                                    textColor: Colors.white,
                                    isLoading: state is AuthLoading,
                                    onPressed: state is AuthLoading
                                        ? null
                                        : _submitRegister,
                                  )
                                  .animate(delay: 400.ms)
                                  .fade()
                                  .slideY(begin: 0.1),

                              const SizedBox(height: 30),

                              Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Already have an account? ',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginPage(),
                                          ),
                                        ),
                                        child: const Text(
                                          'Login Now',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  .animate(delay: 450.ms)
                                  .fade()
                                  .slideY(begin: 0.1),

                              const SizedBox(height: 10),

                              Center(
                                    child: TextButton(
                                      onPressed: () {
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
                                  .animate(delay: 500.ms)
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

  void _submitRegister() {
    // 🚀 RESTORED: Ensures they pick a country before Firebase crashes!
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Country'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().registerWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        country: _selectedCountry,
        region: _regionCtrl.text.trim(),
      );
    } else {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    }
  }
}
