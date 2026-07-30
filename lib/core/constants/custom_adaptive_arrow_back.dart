import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomAdaptiveArrowBack extends StatelessWidget {
  const CustomAdaptiveArrowBack({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      defaultTargetPlatform == TargetPlatform.android
          ? Icons.arrow_back
          : Icons.arrow_back_ios_new,
      color: Colors.black,
      size: 20,
    );
  }
}
