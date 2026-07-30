import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final bool enabled;
  // ✅ NEW PROPS
  final int? maxLength;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
    this.maxLength,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        enabled: enabled,
        maxLength: maxLength,
        keyboardType: keyboardType,
        cursorColor: AppColors.primary,

        style: TextStyle(color: Colors.black),
        // This ensures the validation error or counter doesn't shift the layout too aggressively
        // textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF7F8F9),

          // ✅ CRITICAL: Do NOT set this to zero.
          // Keep it at 16 or 18 to give the text "breathing room" (batting).
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF8391A1)),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,

          // ✅ Optional: Reduces extra height if the counter makes it too tall
          isDense: true,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.35)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.red, width: 1.5),
          ),
        ),
      ),
    );
  }
}
