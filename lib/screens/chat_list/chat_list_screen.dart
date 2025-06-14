import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datingapp/models/conversation_model.dart';
import 'package:datingapp/screens/individual_chat/individual_chat_screen.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Conversas', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE94057),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _currentUser == null
          ? const Center(child: Text("Faça login para ver suas conversas."))
          : StreamBuilder<QuerySnapshot>(
              // A query busca na coleção 'chats' os documentos onde o array 'users'
              // contém o ID do usuário atual. E ordena pelo mais recente.
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('users', arrayContains: _currentUser!.uid)
                  .orderBy('lastMessageTimestamp', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Ocorreu um erro.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum match ainda.\nContinue procurando!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final chatDocs = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: chatDocs.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300, height: 1),
                  itemBuilder: (context, index) {
                    final chatDoc = chatDocs[index];
                    final chatData = chatDoc.data() as Map<String, dynamic>;
                    
                    // Pega a lista de IDs de usuários do chat
                    final List<dynamic> users = chatData['users'];
                    // Encontra o ID da outra pessoa na conversa
                    final String otherUserId = users.firstWhere((uid) => uid != _currentUser!.uid);

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                      builder: (context, userSnapshot) {

                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            leading: CircleAvatar(radius: 28, backgroundColor: Colors.grey),
                            title: Text('Carregando...'),
                          );
                        }

                        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                          return const ListTile(title: Text('Usuário não encontrado'));
                        }

                        final otherUserData = userSnapshot.data!.data() as Map<String, dynamic>;
                        
                        // Cria um objeto Conversation dinamicamente com os dados buscados
                        final conversation = Conversation(
                          name: '${otherUserData['firstName']} ${otherUserData['lastName']}',
                          imageUrl: otherUserData['profileImageUrl'] ?? 'lib/assets/placeholder.png', // Use um placeholder se não houver imagem
                          userId: otherUserId,
                        );

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: conversation.imageUrl.startsWith('http')
                              ? NetworkImage(conversation.imageUrl)
                              : AssetImage(conversation.imageUrl) as ImageProvider,
                          ),
                          title: Text(conversation.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            chatData['lastMessage'] ?? 'Inicie a conversa...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => IndividualChatScreen(conversation: conversation),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}