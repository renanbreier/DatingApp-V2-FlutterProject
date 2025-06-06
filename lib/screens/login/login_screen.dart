import 'package:datingapp/screens/email_login/email_login_screen.dart';
import 'package:flutter/material.dart';

import 'package:datingapp/helpers/navigation.dart';
import 'package:datingapp/screens/login/widgets/social_button.dart';
import 'package:datingapp/screens/phone_number/phone_number_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'lib/assets/logo.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Para continuar, cadastre-se',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => const EmailLoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE94057),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continuar com o e-mail',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => navigateTo(context, const PhoneNumberScreen()),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Usar número de telefone',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFE94057),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('Inscreva-se com'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SocialButton(assetPath: 'lib/assets/icons/facebook.png'),
                          SocialButton(assetPath: 'lib/assets/icons/google.png'),
                          SocialButton(assetPath: 'lib/assets/icons/apple.png'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Termos de uso',
                    style: TextStyle(
                      color: Color(0xFFE94057),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(width: 24),
                  Text(
                    'Política de privacidade',
                    style: TextStyle(
                      color: Color(0xFFE94057),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
