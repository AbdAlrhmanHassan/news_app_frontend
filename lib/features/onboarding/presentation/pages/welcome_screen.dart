import 'package:flutter/material.dart';
import 'package:news_app_frontend/features/auth/presentation/pages/auth_welcome_page.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
 
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // --- TOP RIGHT WATERMARK ---
            Positioned(
              top: -50,
              right: -90,
              child: Icon(
                Icons.headphones_rounded,
                size: 400,
                color: AppColors.primary.withOpacity(0.08),
              ),
            ),

            // --- 🚀 NEW: BOTTOM LEFT TYPOGRAPHIC WATERMARK ---
            Positioned(
              bottom: 110, // Floats nicely above the button
              left: 10, // Bleeds slightly off the left edge for style
              child: Text(
                '3m',
                style: TextStyle(
                  fontSize: 130, // Massive size
                  fontWeight: FontWeight.w900, // Ultra bold
                  letterSpacing: -15, // Pulls the '3' and 'm' tightly together
                  height: 1.0,
                  color: AppColors.primary.withOpacity(
                    0.03,
                  ), // Slightly softer than the headphones
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 4),

                    // --- APP ICON / LOGO ---
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.headphones,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- PUNCHY TYPOGRAPHY ---
                    const Text(
                      'Press play.\nKeep moving.',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- SUBTITLE ---
                    const Text(
                      'Personalized 3-minute news bites, perfectly curated for your commute or workout.',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // --- CUSTOM BUTTON ---
                    CustomButton(
                      text: 'Get Started',
                      textColor: Colors.white,
                      backgroundColor: AppColors.primary,
                      trailingIcon: Icons.arrow_forward_rounded,
                      hasShadow: true,
                      onPressed: () async {
                        await SharedPrefsService.saveBool(
                          'is_first_open',
                          false,
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthWelcomePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
