import 'package:flutter/material.dart';

// 🚀 Just a completely normal Flutter widget!
class SimpleNewsWidget extends StatelessWidget {
  const SimpleNewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      width: 200,
      height: 200,
      child: const Center(
        child: Text(
          'It works! 🎉',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
