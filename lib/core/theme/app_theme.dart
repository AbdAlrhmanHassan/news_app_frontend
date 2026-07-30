// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../constants/app_colors.dart';
// import '../constants/app_text_styles.dart';

// class AppTheme {
//   AppTheme._();

//   static ThemeData lightTheme(String languageCode) {
//     // 1. Get the standard set of text styles (which already handles bold/normal correctly)
//     final baseTextTheme = ThemeData.light().textTheme;

//     return ThemeData(
//       useMaterial3: true,

//       colorScheme: ColorScheme.fromSeed(
//         seedColor: AppColors.primary,
//         primary: AppColors.primary,
//         surface: Colors.white,
//       ),

//       scaffoldBackgroundColor: Colors.white,

//       // 2. Apply the Font Family on top of the Base Theme
//       textTheme: languageCode == 'ar'
//           ? GoogleFonts.cairoTextTheme(baseTextTheme)
//           : GoogleFonts.plusJakartaSansTextTheme(baseTextTheme),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: false,
//         titleTextStyle: const TextStyle(
//           color: Colors.black,
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//     );
//   }
// }
