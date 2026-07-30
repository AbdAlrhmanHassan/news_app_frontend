// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Needed for provider detection
// import 'package:ajloun_booking/core/assets_gen/assets.gen.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/widgets/custom_button.dart';
// import '../../../../core/widgets/custom_text_field.dart';
// import '../../../../generated/l10n.dart'; // ✅ Added localization import
// import '../../../auth/presentation/pages/auth_welcome_page.dart';
// import '../../../auth/presentation/pages/forgot_password/forgot_password_page.dart';
// import '../cubit/auth_cubit.dart';
// import '../cubit/auth_state.dart';

// class ReAuthenticationPage extends StatefulWidget {
//   const ReAuthenticationPage({super.key});

//   @override
//   State<ReAuthenticationPage> createState() => _ReAuthenticationPageState();
// }

// class _ReAuthenticationPageState extends State<ReAuthenticationPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _emailCtrl;
//   final TextEditingController _passCtrl = TextEditingController();

//   bool _isPasswordVisible = false;
//   bool _isSocialUser = false; // ✅ Flag to switch UI

//   @override
//   void initState() {
//     super.initState();
//     final user = context.read<AuthCubit>().getCurrentUser();
//     _emailCtrl = TextEditingController(text: user?.email ?? "");

//     // 1. 🕵️ Detect if user is Social (Google/Apple)
//     final firebaseUser = FirebaseAuth.instance.currentUser;
//     if (firebaseUser != null) {
//       for (var provider in firebaseUser.providerData) {
//         if (provider.providerId == 'google.com' ||
//             provider.providerId == 'apple.com') {
//           _isSocialUser = true;
//           break;
//         }
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _emailCtrl.dispose();
//     _passCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final strings = S.of(context); // ✅ Initialize localizations

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           strings.securityCheckTitle, // ✅ Localized
//           style: const TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: BlocConsumer<AuthCubit, AuthState>(
//         listener: (context, state) {
//           if (state is Unauthenticated) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   strings.accountDeletedSuccessfully,
//                 ), // ✅ Localized
//                 backgroundColor: Colors.grey,
//               ),
//             );
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const AuthWelcomePage()),
//               (route) => false,
//             );
//           } else if (state is AuthFailure) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           final isLoading = state is AuthLoading;

//           return SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         _isSocialUser
//                             ? Icons.verified_user_outlined
//                             : Icons.lock_clock_outlined,
//                         size: 40,
//                         color: Colors.red,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   Center(
//                     child: Text(
//                       strings.deleteYourAccount, // ✅ Localized
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // 2. ✅ Smart Text: Change message based on user type
//                   Text(
//                     _isSocialUser
//                         ? strings
//                               .socialSecurityMessage // ✅ Localized
//                         : strings.passwordSecurityMessage, // ✅ Localized
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Colors.grey,
//                       fontSize: 14,
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 32),

//                   Text(
//                     strings.emailAddressLabel, // ✅ Localized
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   IgnorePointer(
//                     ignoring: true,
//                     child: CustomTextField(
//                       controller: _emailCtrl,
//                       hintText: strings
//                           .emailHint, // ✅ Reused from previous localization
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // 3. ✅ Switch UI: Password Field OR Info Box
//                   if (!_isSocialUser) ...[
//                     Text(
//                       strings.passwordLabel, // ✅ Localized
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     CustomTextField(
//                       controller: _passCtrl,
//                       hintText: strings
//                           .enterYourPassword, // ✅ Reused from previous localization
//                       isPassword: !_isPasswordVisible,
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _isPasswordVisible
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color: Colors.grey,
//                         ),
//                         onPressed: () => setState(
//                           () => _isPasswordVisible = !_isPasswordVisible,
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return strings.passwordIsRequired; // ✅ Localized
//                         }
//                         return null;
//                       },
//                     ),
//                     Align(
//                       alignment: Alignment
//                           .centerRight, // Reverses automatically in RTL
//                       child: TextButton(
//                         onPressed: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 ForgotPasswordPage(userEmail: _emailCtrl.text),
//                           ),
//                         ),
//                         child: Text(
//                           strings
//                               .forgotPasswordTitle, // ✅ Reused from previous localization
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ] else ...[
//                     // INFO BOX for Social Users
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: AppColors.primary.withOpacity(0.2),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.info_outline,
//                             color: AppColors.primary,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               strings.socialSignInPrompt, // ✅ Localized
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],

//                   const SizedBox(height: 30),

//                   // 4. ✅ Button Action Logic
//                   if (isLoading)
//                     const Center(
//                       child: CircularProgressIndicator(color: Colors.red),
//                     )
//                   else
//                     CustomButton(
//                       text: _isSocialUser
//                           ? strings
//                                 .verifyAndDeleteButton // ✅ Localized
//                           : strings.confirmDeleteButton, // ✅ Localized
//                       backgroundColor: Colors.red,
//                       textColor: Colors.white,
//                       onPressed: _submitDelete,
//                     ),

//                   const SizedBox(height: 16),

//                   if (!isLoading)
//                     Center(
//                       child: TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: Text(
//                           strings
//                               .cancelButton, // ✅ Reused from previous localization
//                           style: const TextStyle(color: Colors.grey),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _submitDelete() {
//     if (_isSocialUser) {
//       // ✅ 5. Call Social Delete Logic
//       context.read<AuthCubit>().deleteAccountSocial();
//     } else {
//       // ✅ 6. Call Password Delete Logic
//       if (_formKey.currentState!.validate()) {
//         context.read<AuthCubit>().deleteAccount(
//           password: _passCtrl.text.trim(),
//         );
//       }
//     }
//   }
// }
