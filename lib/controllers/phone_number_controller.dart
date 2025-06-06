import 'package:flutter/material.dart';
import 'package:datingapp/screens/verification/verification_screen.dart';

class PhoneNumberController {
  String fullPhoneNumber = '';
  bool isValid = false;

  void onPhoneChanged(String number, int length) {
    fullPhoneNumber = number;
    isValid = length >= 11;
  }

  void goToVerification(BuildContext context) {
    if (isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(phoneNumber: fullPhoneNumber),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O número está incompleto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

