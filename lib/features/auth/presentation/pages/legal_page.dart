// import 'package:flutter/material.dart';
// import '../../../../core/constants/app_colors.dart';

// // ✅ Define an Enum to control which content to show
// enum LegalViewMode { privacy, terms }

// class LegalPage extends StatelessWidget {
//   final LegalViewMode mode;

//   const LegalPage({super.key, required this.mode});

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Dynamic Title based on the mode
//     final String title = mode == LegalViewMode.privacy
//         ? "Privacy Policy"
//         : "Terms of Service";

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           title,
//           style: const TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ✅ Only show the section that matches the mode
//             if (mode == LegalViewMode.privacy) ..._buildPrivacySection(),
//             if (mode == LegalViewMode.terms) ..._buildTermsSection(),

//             const SizedBox(height: 40),
//             Center(
//               child: Text(
//                 "Last Updated: February 2026",
//                 style: TextStyle(color: Colors.grey[400], fontSize: 12),
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildPrivacySection() {
//     return [
//       _header("1. Data We Collect"),
//       _paragraph(
//         "We collect information you provide directly to us, such as your name, email address, and phone number when you register an account. We may also collect data about your location to suggest nearby places.",
//       ),
//       _header("2. How We Use Your Data"),
//       _paragraph(
//         "We use your data to:\n• Process your bookings.\n• Send you confirmation emails.\n• Improve our app functionality.\n• Ensure account security.",
//       ),
//       _header("3. Account Deletion"),
//       _paragraph(
//         "You have the right to delete your account at any time. This will permanently remove your personal data from our active databases. You can find this option in the Settings menu.",
//       ),
//       _header("4. Third-Party Services"),
//       _paragraph(
//         "We use Google Firebase for authentication and database services. Your data is stored securely on Google's servers.",
//       ),
//     ];
//   }

//   List<Widget> _buildTermsSection() {
//     return [
//       _header("1. User Accounts"),
//       _paragraph(
//         "You are responsible for safeguarding your password. You agree not to disclose your password to any third party. You must notify us immediately upon becoming aware of any breach of security.",
//       ),
//       _header("2. Booking Rules"),
//       _paragraph(
//         "All bookings made through the app are subject to availability. Cancellations must be made at least 24 hours in advance for a full refund (if applicable).",
//       ),
//       _header("3. Prohibited Conduct"),
//       _paragraph(
//         "You agree not to misuse the app or help anyone else do so. You will not post content that is offensive, harmful, or violates the rights of others.",
//       ),
//       _header("4. Limitation of Liability"),
//       _paragraph(
//         "Ajloun Booking is not liable for any indirect, incidental, or consequential damages arising from your use of the service.",
//       ),
//     ];
//   }

//   Widget _header(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20, bottom: 8),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _paragraph(String text) {
//     return Text(
//       text,
//       style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
//     );
//   }
// }
