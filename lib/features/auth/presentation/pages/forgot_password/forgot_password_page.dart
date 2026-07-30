import 'package:flutter/material.dart';

import '../../../../../core/constants/custom_text_field.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/alert_utils.dart';
import '../../../../../core/widgets/custom_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.userEmail});
  final String? userEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late TextEditingController _emailController;
  bool _isFieldLocked = false;

  // Added to simulate loading state for UI testing
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userEmail ?? "");

    if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
      _isFieldLocked = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              _isFieldLocked
                  ? 'We will send a reset link to your registered email.'
                  : 'Enter your email to receive a password reset link.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            IgnorePointer(
              ignoring: _isFieldLocked,
              child: Opacity(
                opacity: _isFieldLocked ? 0.7 : 1.0,
                child: CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icon(
                    _isFieldLocked ? Icons.lock_outline : Icons.email_outlined,
                    color: _isFieldLocked ? Colors.grey : AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            CustomButton(
              text: _isLoading ? 'Sending...' : 'Send Link',
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              onPressed: _isLoading ? null : _submitResetRequest,
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isFieldLocked ? 'Go back to ' : 'Remember password? ',
                  style: const TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    _isFieldLocked ? 'Settings' : 'Login',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _submitResetRequest() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay for UI testing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSuccessDialog(context);
      }
    });
  }

  void _showSuccessDialog(BuildContext context) {
    AlertUtils.showMessage(
      title: 'Check your email',
      context: context,
      message: 'A password reset link has been sent to your email.',
    );
  }
}
