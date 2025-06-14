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
      if (mounted) Navigator.of(context).pop();
      return;
    }
    _currentUserId = currentUser.uid;
    final otherUserId = widget.conversation.userId;
    if (_currentUserId!.compareTo(otherUserId) > 0) {
      _chatId = '$_currentUserId-$otherUserId';
    } else {
      _chatId = '$otherUserId-$_currentUserId';
    }
    setState(() {});
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty || _chatId == null || _currentUserId == null) return;
    final messageText = _textController.text.trim();
    _textController.clear();
    final messageData = {'text': messageText, 'senderId': _currentUserId, 'timestamp': FieldValue.serverTimestamp()};
    await FirebaseFirestore.instance.collection('chats').doc(_chatId).collection('messages').add(messageData);
    await FirebaseFirestore.instance.collection('chats').doc(_chatId).set({'users': [_currentUserId, widget.conversation.userId], 'lastMessage': messageText, 'lastMessageTimestamp': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Future<void> _removeMatch() async {
    if (_chatId == null || _currentUserId == null) return;
    if (mounted) Navigator.of(context).pop();
    try {
      await FirebaseFirestore.instance.collection('chats').doc(_chatId).delete();
      final otherUserId = widget.conversation.userId;
      final likesRef = FirebaseFirestore.instance.collection('likes');
      var likeQuery = await likesRef.where('likerUid', isEqualTo: _currentUserId).where('likedUid', isEqualTo: otherUserId).get();
      for (var doc in likeQuery.docs) { await doc.reference.delete(); }
      var reciprocalLikeQuery = await likesRef.where('likerUid', isEqualTo: otherUserId).where('likedUid', isEqualTo: _currentUserId).get();
      for (var doc in reciprocalLikeQuery.docs) { await doc.reference.delete(); }
    } catch (e) {
      print('Erro ao remover match: $e');
    }
  }

  void _showConfirmationDialog({required String title, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(children: [ const Icon(Icons.warning_amber_rounded, color: Colors.red), const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)) ]),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(child: const Text('Não', style: TextStyle(color: Colors.black54)), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Sim'), onPressed: () { Navigator.of(ctx).pop(); onConfirm(); }),
        ],
      ),
    );
  }

  // ⭐ 1. A FUNÇÃO AGORA USA 'showDialog' E CHAMA UM WIDGET CUSTOMIZADO
  void _showOptionsDialog() {
    showDialog(
      context: context,
      // barrierDismissible: false, // Opcional: impede que o diálogo feche ao tocar fora
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: _buildOptionsContent(context),
        );
      },
    );
  }

  // ⭐ 2. NOVO WIDGET PARA CONSTRUIR O CONTEÚDO DO DIÁLOGO DE OPÇÕES
  Widget _buildOptionsContent(BuildContext dialogContext) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE94057),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Opções', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Botão Denunciar (sem ação por enquanto)
          _buildOptionButton(
            text: 'Denunciar',
            onPressed: () {
              Navigator.of(dialogContext).pop();
              print('Botão Denunciar pressionado');
            },
          ),
          const SizedBox(height: 8),
          // Botão Remover Match
          _buildOptionButton(
            text: 'Remover Match',
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showConfirmationDialog(title: 'Remover Match?', onConfirm: _removeMatch);
            },
          ),
          const SizedBox(height: 8),
          // Botão Bloquear
          _buildOptionButton(
            text: 'Bloquear',
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showConfirmationDialog(title: 'Bloquear usuário?', onConfirm: _removeMatch);
            },
          ),
        ],
      ),
    );
  }

  // ⭐ 3. WIDGET AUXILIAR PARA CRIAR OS BOTÕES DO DIÁLOGO
  Widget _buildOptionButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFE94057),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
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
        backgroundColor: const Color(0xFFE94057),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        title: Row(children: [ CircleAvatar(backgroundImage: AssetImage(widget.conversation.imageUrl), radius: 20), const SizedBox(width: 12), Text(widget.conversation.name, style: const TextStyle(color: Colors.white, fontSize: 18)) ]),
        actions: [
          IconButton(
            // A ação do botão agora chama a nova função de diálogo
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('chats').doc(_chatId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Diga olá! Inicie a conversa.'));
                      if (snapshot.hasError) return const Center(child: Text('Ocorreu um erro ao carregar as mensagens.'));
                      final messages = snapshot.data!.docs;
                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
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
        child: Text(text, style: TextStyle(color: isSentByMe ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5)]),
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