import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  // Customization Props
  final double? width;
  final double height;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final double borderWidth;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;

  // 🚀 NEW: Floating shadow toggle
  final bool hasShadow;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 56.0,
    this.borderColor,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 16.0,
    this.borderWidth = 1.0,
    this.fontSize = 16.0,
    this.padding,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.hasShadow =
        false, // Defaults to false so it doesn't break your existing UI!
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the button is effectively disabled
    final bool isDisabled = onPressed == null || isLoading;
    final Color effectiveBgColor = backgroundColor ?? AppColors.primary;

    // Determine splash color based on text color
    final Color splashColor = textColor == Colors.white
        ? Colors.white.withOpacity(0.2)
        : AppColors.secondary.withOpacity(0.1);

    // Calculate effective text/icon color once to keep it DRY
    final Color effectiveTextColor =
        textColor ??
        (effectiveBgColor == AppColors.primary
            ? Colors.white
            : AppColors.primary);

    return Container(
      width: width,
      height: height,
      // 🚀 NEW: The Floating Shadow Logic!
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hasShadow && !isDisabled
            ? [
                BoxShadow(
                  color: effectiveBgColor.withOpacity(
                    0.4,
                  ), // Matches the button color!
                  blurRadius: 12,
                  offset: const Offset(0, 5), // Pushes the shadow down to float
                ),
              ]
            : [], // No shadow if disabled or not requested
      ),
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDisabled
              ? effectiveBgColor.withOpacity(0.5)
              : effectiveBgColor,
          padding: padding,
          side: BorderSide(
            color:
                borderColor ??
                (backgroundColor != null
                    ? Colors.transparent
                    : AppColors.primary),
            width: borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          foregroundColor: splashColor,
          disabledForegroundColor: effectiveTextColor.withOpacity(0.5),
          elevation: 0, // Remove native elevation to let the BoxShadow shine
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: effectiveTextColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, color: effectiveTextColor, size: 22),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: effectiveTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, color: effectiveTextColor, size: 22),
                  ],
                ],
              ),
      ),
    );
  }
}
