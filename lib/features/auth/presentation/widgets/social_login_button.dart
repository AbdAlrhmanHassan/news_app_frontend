import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/theme/app_colors.dart';

class SocialAuthButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onTap;
  final double? bottomMargin;

  // Customization
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;

  // 🚀 NEW: Controls the loading state
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onTap,
    this.bottomMargin,
    this.iconColor,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF1E232C),
    this.borderColor,
    this.isLoading = false, // Defaults to false so it doesn't break other pages
  });

  @override
  Widget build(BuildContext context) {
    final Color splashColor = textColor == Colors.white
        ? Colors.white.withOpacity(0.12)
        : AppColors.primary.withOpacity(0.1);

    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin ?? 0),
      width: double.infinity,
      height: 56.0,
      child: OutlinedButton(
        // 🚀 CRITICAL: If isLoading is true, onPressed becomes null. This disables the button!
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,

          // Match the exact Border Radius (12.0)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          // Match the Border Color logic
          side: BorderSide(
            color: borderColor ?? const Color(0xFFE8ECF4),
            width: 1.0,
          ),

          // Same Splash Effect
          foregroundColor: splashColor,
          elevation: 0,
        ),
        // 🚀 NEW: Swap between the Spinner and the normal Row based on isLoading
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  // Matches the spinner color to the text color (White for Apple, Dark for Google)
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppColors.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    height: 24,
                    colorFilter: iconColor != null
                        ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
