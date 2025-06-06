import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final List<Map<String, dynamic>> settings = const [
    {'icon': Icons.person, 'label': 'Perfil'},
    {'icon': Icons.lock, 'label': 'Privacidade'},
    {'icon': Icons.notifications, 'label': 'Notificações'},
    {'icon': Icons.language, 'label': 'Idioma'},
    {'icon': Icons.palette, 'label': 'Tema'},
    {'icon': Icons.help, 'label': 'Ajuda'},
    {'icon': Icons.info, 'label': 'Sobre'},
    {'icon': Icons.logout, 'label': 'Sair'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = settings[index];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(item['icon'], size: 30, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(item['label'], style: const TextStyle(fontSize: 14)),
              ],
            );
          },
        ),
      ),
    );
  }
}
