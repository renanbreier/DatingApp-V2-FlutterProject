import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datingapp/models/conversation_model.dart';
import 'package:flutter/material.dart';

class IndividualChatScreen extends StatefulWidget {
  final Conversation conversation;

  const IndividualChatScreen({super.key, required this.conversation});

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _currentUserId;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    _setupChat();
  }
  
  void _setupChat() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("ERRO: Usuário não está logado para iniciar o chat.");
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    
    _currentUserId = currentUser.uid;
    
    // Lógica para criar um ID de chat consistente e previsível entre dois usuários
    final otherUserId = widget.conversation.userId;
    if (_currentUserId!.compareTo(otherUserId) > 0) {
      _chatId = '$_currentUserId-$otherUserId';
    } else {
      _chatId = '$otherUserId-$_currentUserId';
    }
    // Para garantir que o widget seja reconstruído com o _chatId definido
    setState(() {});
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty || _chatId == null || _currentUserId == null) {
      return;
    }

    final messageText = _textController.text.trim();
    // Limpa o campo de texto imediatamente para uma melhor experiência do usuário
    _textController.clear();

    final messageData = {
      'text': messageText,
      'senderId': _currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Adiciona a mensagem à subcoleção de mensagens
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add(messageData);

    // Atualiza o documento principal do chat com a última mensagem
    await FirebaseFirestore.instance.collection('chats').doc(_chatId).set({
      'users': [_currentUserId, widget.conversation.userId],
      'lastMessage': messageText,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Rola para a mensagem mais recente
    _scrollController.animateTo(
      0.0, // O topo da lista, já que ela está invertida
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFFE94057),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(widget.conversation.imageUrl), radius: 20),
            const SizedBox(width: 12),
            Text(widget.conversation.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(_chatId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'Diga olá! Inicie a conversa.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Ocorreu um erro ao carregar as mensagens.'));
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Importante para o layout do chat
                        padding: const EdgeInsets.all(16.0),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final messageDoc = messages[index];
                          final messageData = messageDoc.data() as Map<String, dynamic>;
                          final isSentByMe = messageData['senderId'] == _currentUserId;

                          return _buildMessageBubble(messageData['text'], isSentByMe);
                        },
                      );
                    },
                  ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isSentByMe) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSentByMe ? const Color(0xFFE94057) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isSentByMe ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isSentByMe ? const Radius.circular(0) : const Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isSentByMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), 
            spreadRadius: 1, 
            blurRadius: 5
          )
        ]
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration.collapsed(hintText: 'Digite uma mensagem...'),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: const Color(0xFFE94057),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}