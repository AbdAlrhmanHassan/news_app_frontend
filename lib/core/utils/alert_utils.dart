import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';

class AlertUtils {
  // ℹ️ SHOW SIMPLE MESSAGE (OK Button only)
  static void showMessage({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText, // ✅ Made nullable to use localized default
    VoidCallback? onCreate,
  }) {
    // final strings = S.of(context); // ✅ Initialize localizations
    // final defaultButtonText = buttonText ?? strings.okButton;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'defaultButtonText', // ✅ Localized Default
                height: 48,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                borderColor: Colors.transparent,
                onPressed: () {
                  Navigator.pop(ctx);
                  if (onCreate != null) onCreate();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⚠️ SHOW CONFIRMATION DIALOG (Cancel / Yes)
  static void showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? cancelText, // ✅ Made nullable
    String? confirmText, // ✅ Made nullable
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: isDestructive
              ? BorderSide.none
              : const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDestructive
                      ? Icons.warning_amber_rounded
                      : Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'defaultCancelText', // ✅ Localized Default
                      height: 48,
                      backgroundColor: Colors.white,
                      textColor: Colors.black87,
                      borderColor: Colors.grey.shade300,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'defaultConfirmText', // ✅ Localized Default
                      height: 48,
                      backgroundColor: isDestructive
                          ? AppColors.red
                          : AppColors.primary,
                      textColor: Colors.white,
                      borderColor: Colors.transparent,
                      onPressed: () {
                        Navigator.pop(ctx);
                        onConfirm();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⏳ SHOW LOADING DIALOG
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
            ],
          ),
          child: const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
