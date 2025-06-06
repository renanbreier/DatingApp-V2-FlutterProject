import 'package:flutter/material.dart';

class VerificationDigitBox extends StatelessWidget {
  final String digit;

  const VerificationDigitBox({super.key, required this.digit});

  @override
  Widget build(BuildContext context) {
    final isFilled = digit.isNotEmpty;

    return Container(
      width: 56,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isFilled ? const Color(0xFFE94057) : Colors.white,
        border: Border.all(color: const Color(0xFFE94057)),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isFilled ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}