import 'package:flutter/material.dart';

class AppColors {
  // --- PRIMARY BRANDING ---
  // The deep, elegant burgundy/red you requested
  static const Color primary = Color(0xFF95271D);

  // A softer, complementary blush/rose color for accents
  static const Color secondary = Color(0xFFD98880);

  // --- LIGHT THEME BACKGROUNDS ---
  // Pure white for cards and floating chips so they pop against the gradient
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // --- TEXT COLORS (Flipped for Light Theme) ---
  // Almost black, but with a tiny hint of warmth to match the red
  static const Color textDark = Color(0xFF2C1A19);
  static const Color textGrey = Color(0xFF8A7D7C);

  static const Color red = Colors.red;

  // --- DYNAMIC LIGHT GRADIENT ---
  static LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    // The magic is here: 0.0 to 0.4 stays solid white!
    stops: const [0.0, 0.6, 1.0],
    colors: [
      const Color(0xFFFFFFFF), // 0% (Top): Pure clean white
      const Color(
        0xFFFFFFFF,
      ), // 40% (Middle): STILL pure white! The gradient starts after this point.
      const Color(0xFFFFFFFF), // 100% (Bottom): A very soft, elegant warm blush
    ],
  );
}
