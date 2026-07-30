// import 'dart:developer';

// import 'package:ajloun_booking/core/utils/snack_bar_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/widgets/custom_button.dart';
// import '../../../core/widgets/custom_text_field.dart';
// import '../../../../core/widgets/user_profile_avatar.dart';
// import '../../../../generated/l10n.dart'; // ✅ Added localization import
// import 'cubit/user_cubit.dart';

// class EditProfilePage extends StatefulWidget {
//   const EditProfilePage({super.key});

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   late TextEditingController _displayNameCtrl;
//   late TextEditingController _fullNameCtrl;
//   late TextEditingController _phoneCtrl;
//   late TextEditingController _emailCtrl;

//   @override
//   void initState() {
//     super.initState();

//     final user = context.read<UserCubit>().fullUserData;
//     log(
//       'User data in EditProfilePage initState: ${user?.displayName ?? "No user data"}',
//     );

//     if (user != null) {
//       _displayNameCtrl = TextEditingController(text: user.displayName);
//       _fullNameCtrl = TextEditingController(text: user.fullName ?? '');
//       _phoneCtrl = TextEditingController(text: user.phoneNumber ?? '');
//       _emailCtrl = TextEditingController(text: user.email);
//     } else {
//       _displayNameCtrl = TextEditingController();
//       _fullNameCtrl = TextEditingController();
//       _phoneCtrl = TextEditingController();
//       _emailCtrl = TextEditingController();
//     }
//   }

//   @override
//   void dispose() {
//     _displayNameCtrl.dispose();
//     _fullNameCtrl.dispose();
//     _phoneCtrl.dispose();
//     _emailCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final strings = S.of(context); // ✅ Initialize localizations

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           strings.editProfileTitle, // ✅ Localized
//           style: const TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Directionality.of(context) == TextDirection.rtl
//                 ? Icons.arrow_forward_ios
//                 : Icons.arrow_back_ios_new,
//             color: Colors.black,
//             size: 20,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: BlocConsumer<UserCubit, UserState>(
//         listener: (context, state) {
//           if (state is UserLoaded) {
//             SnackBarUtils.showSuccess(
//               context,
//               strings.profileUpdatedSuccessfully,
//             ); // ✅ Localized
//             Navigator.pop(context);
//           } else if (state is UserError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           final isLoading = state is UserLoading;
//           final user = context.watch<UserCubit>().fullUserData;

//           return SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: UserProfileAvatar(
//                       photoUrl: user?.photoUrl,
//                       displayName: user?.displayName,
//                       radius: 55,
//                       fontSize: 40,
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   _buildSectionHeader(
//                     strings.accountInformation,
//                   ), // ✅ Localized
//                   const SizedBox(height: 10),
//                   _buildReadOnlyEmailField(),

//                   const SizedBox(height: 25),

//                   _buildSectionHeader(strings.personalDetails), // ✅ Localized
//                   const SizedBox(height: 12),

//                   _buildLabel(strings.displayName), // ✅ Localized
//                   CustomTextField(
//                     controller: _displayNameCtrl,
//                     hintText: strings.displayNameHint, // ✅ Localized
//                     maxLength: 14,
//                     validator: (v) {
//                       if (v == null || v.isEmpty)
//                         return strings.requiredField; // ✅ Localized
//                       return null;
//                     },
//                   ),

//                   const SizedBox(height: 0),

//                   _buildLabel(strings.fullName), // ✅ Localized
//                   CustomTextField(
//                     controller: _fullNameCtrl,
//                     hintText: strings.fullNameHint, // ✅ Localized
//                   ),

//                   const SizedBox(height: 4),

//                   _buildLabel(strings.phoneNumber), // ✅ Localized
//                   CustomTextField(
//                     controller: _phoneCtrl,
//                     hintText: strings.phoneNumberHint, // ✅ Localized
//                     keyboardType: TextInputType.phone,
//                   ),

//                   const SizedBox(height: 40),

//                   if (isLoading)
//                     const Center(
//                       child: CircularProgressIndicator(
//                         color: AppColors.primary,
//                       ),
//                     )
//                   else
//                     SafeArea(
//                       child: CustomButton(
//                         text: strings.saveChanges, // ✅ Localized
//                         backgroundColor: AppColors.primary,
//                         textColor: Colors.white,
//                         onPressed: () => _submitChanges(strings),
//                       ),
//                     ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildReadOnlyEmailField() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.email_outlined, color: Colors.grey, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _emailCtrl.text,
//                   style: TextStyle(
//                     color: Colors.grey[700],
//                     fontWeight: FontWeight.w500,
//                     fontSize: 15,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: Colors.black87,
//       ),
//     );
//   }

//   Widget _buildLabel(String label) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8, left: 4),
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//           color: Colors.black54,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }

//   void _submitChanges(S strings) {
//     if (_formKey.currentState!.validate()) {
//       FocusScope.of(context).unfocus();

//       final currentUser = context.read<UserCubit>().fullUserData;
//       if (currentUser == null) return;

//       final newDisplayName = _displayNameCtrl.text.trim();
//       final newFullName = _fullNameCtrl.text.trim();
//       final newPhone = _phoneCtrl.text.trim();

//       String? displayNameToUpdate;
//       String? fullNameToUpdate;
//       String? phoneToUpdate;
//       bool hasChanges = false;

//       if (newDisplayName != currentUser.displayName) {
//         displayNameToUpdate = newDisplayName;
//         hasChanges = true;
//       }
//       if (newFullName != (currentUser.fullName ?? '')) {
//         fullNameToUpdate = newFullName;
//         hasChanges = true;
//       }
//       if (newPhone != (currentUser.phoneNumber ?? '')) {
//         phoneToUpdate = newPhone;
//         hasChanges = true;
//       }

//       if (!hasChanges) {
//         SnackBarUtils.showInfo(
//           context,
//           strings.noChangesDetected,
//         ); // ✅ Localized
//         return;
//       }

//       context.read<UserCubit>().updateProfile(
//         displayName: displayNameToUpdate,
//         fullName: fullNameToUpdate,
//         phoneNumber: phoneToUpdate,
//       );
//     }
//   }
// }
