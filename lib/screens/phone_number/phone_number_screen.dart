import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:datingapp/controllers/phone_number_controller.dart';
import 'package:datingapp/widgets/back_arrow.dart';

class PhoneNumberScreen extends StatelessWidget {
  const PhoneNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PhoneNumberController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BackArrow(),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Telefone',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Por favor, insira seu número de telefone válido. Nós lhe enviaremos um código de 4 dígitos para verificar sua conta.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                IntlPhoneField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                  ),
                  initialCountryCode: 'BR',
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (phone) {
                    controller.onPhoneChanged(
                      phone.completeNumber,
                      phone.number.length,
                    );
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => controller.goToVerification(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94057),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}