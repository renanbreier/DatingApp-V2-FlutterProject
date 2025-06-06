import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:datingapp/controllers/verification_controller.dart';
import 'package:datingapp/widgets/back_arrow.dart';
import 'package:datingapp/screens/verification/widgets/verification_digit_box.dart';
import 'package:datingapp/screens/verification/widgets/verification_keyboard.dart';

class VerificationScreen extends StatelessWidget {
  final String phoneNumber;

  const VerificationScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VerificationController(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const BackArrow(),
        body: SafeArea(
          child: Consumer<VerificationController>(
            builder: (context, controller, _) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      phoneNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Digite o código de verificação que enviamos para você",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => VerificationDigitBox(
                          digit: index < controller.enteredDigits.length
                              ? controller.enteredDigits[index]
                              : '',
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    VerificationKeyboard(
                      onTap: (value) => controller.onKeyboardTap(value, context),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Enviar novamente",
                        style: TextStyle(
                          color: Color(0xFFE94057),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
