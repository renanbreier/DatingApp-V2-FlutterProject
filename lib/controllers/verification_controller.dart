import 'package:flutter/material.dart';
import 'package:datingapp/screens/profile/profile_screen.dart';
import 'package:datingapp/helpers/navigation.dart';

class VerificationController extends ChangeNotifier {
  final List<String> _enteredDigits = [];

  List<String> get enteredDigits => List.unmodifiable(_enteredDigits);

  void onKeyboardTap(String value, BuildContext context) {
    if (value == 'del') {
      if (_enteredDigits.isNotEmpty) {
        _enteredDigits.removeLast();
      }
    } else if (_enteredDigits.length < 4) {
      _enteredDigits.add(value);
      if (_enteredDigits.length == 4) {
        _validateCode(context);
      }
    }
    notifyListeners();
  }

  void _validateCode(BuildContext context) {
    final code = _enteredDigits.join('');
    if (code == '6789') {
      navigateTo(context, const ProfileScreen());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código inválido'),
          backgroundColor: Colors.red,
        ),
      );
      _enteredDigits.clear();
      notifyListeners();
    }
  }
}