import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> conversations = [
      {'name': 'Camila Alves', 'message': 'Oi! Tudo bem?', 'image': 'lib/assets/users/user_2.jpg'},
      {'name': 'Peter Parker', 'message': 'Vamos sair hoje?', 'image': 'lib/assets/users/user_1.jpg'},
      {'name': 'Larissa Silva', 'message': 'Adorei suas fotos!', 'image': 'lib/assets/users/user_4.jpg'},
      {'name': 'Tiago Pinheiro', 'message': 'Curte música?', 'image': 'lib/assets/users/user_3.jpg'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversas', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE94057),
         elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        itemCount: conversations.length,
        separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final chat = conversations[index];
          return ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage(chat['image']!)),
            title: Text(chat['name']!),
            subtitle: Text(chat['message']!),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          );
        },
      ),
    );
  }
}