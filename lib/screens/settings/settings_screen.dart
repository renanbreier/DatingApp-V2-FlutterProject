import 'package:firebase_auth/firebase_auth.dart';
import 'package:datingapp/screens/login/login_screen.dart';

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final List<Map<String, dynamic>> settings = const [
    {'icon': Icons.person, 'label': 'Perfil'},
    {'icon': Icons.room_preferences, 'label': 'Preferências'},
    {'icon': Icons.notifications, 'label': 'Notificações'},
    {'icon': Icons.language, 'label': 'Idioma'},
    {'icon': Icons.palette, 'label': 'Tema'},
    {'icon': Icons.help, 'label': 'Ajuda'},
    {'icon': Icons.info, 'label': 'Sobre'},
    {'icon': Icons.logout, 'label': 'Sair', 'isLogout': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Configurações"),
        backgroundColor: const Color(0xFFE94057),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: settings.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final item = settings[index];
            final bool isLogoutButton = item['isLogout'] ?? false;

            return InkWell(
              onTap: () async {
                
                // Lógica para o botão "Sair"
                if (isLogoutButton) {
                  // Primeiro, desconecta o usuário do Firebase
                  await FirebaseAuth.instance.signOut();

                  // Após o logout, verifica se o widget ainda está na tela antes de navegar
                  if (!context.mounted) return;

                  // Leva para a tela de login e remove todas as outras telas da pilha
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                } else {
                  // Aqui você pode adicionar a navegação para as outras telas no futuro
                  print('Clicou em: ${item['label']}');
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isLogoutButton ? Colors.red.withOpacity(0.1) : Colors.grey.shade200,
                      child: Icon(
                        item['icon'], 
                        size: 30, 
                        // Cor do ícone muda se for o botão de logout
                        color: isLogoutButton ? Colors.red : Colors.black87
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item['label'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}