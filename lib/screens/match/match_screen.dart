import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datingapp/screens/profile/profile_screen.dart';
import 'package:datingapp/screens/chat_list/chat_list_screen.dart';
import 'package:datingapp/screens/settings/settings_screen.dart';
import 'package:datingapp/services/notification_service.dart';
import 'package:flutter/material.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  
  // A lista 'users' foi substituída por variáveis de estado
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  int _currentIndex = 0;
  Offset _position = Offset.zero;
  double _rotation = 0.0;
  late AnimationController _controller;
  late Animation<Offset> _animation;
  String? _activeIcon;
  bool _showIcon = false;
  
  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Busca os usuários ao iniciar a tela
    
    _notificationService.init();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.addListener(() { setState(() { _position = _animation.value; _rotation = 0.002 * _position.dx; }); });
    _controller.addStatusListener((status) { if (status == AnimationStatus.completed) { _resetPosition(); } });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      const List<String> userIdsToFetch = [ 'user_1_id', 'user_2_id', 'user_3_id', 'user_4_id' ];
      
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIdsToFetch)
          .get();
      
      final fetchedUsers = usersQuery.docs.map((doc) => doc.data()).toList();

      if (mounted) {
        setState(() {
          _users = fetchedUsers;
          _isLoading = false;
        });
        _precacheNextImage();
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar perfis: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _createChatRoom(String otherUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final chatId = (currentUser.uid.compareTo(otherUserId) > 0)
        ? '${currentUser.uid}-$otherUserId'
        : '$otherUserId-${currentUser.uid}';

    final chatData = {
      'users': [currentUser.uid, otherUserId],
      'lastMessage': '',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    };
    
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set(chatData, SetOptions(merge: true));
    print('Sala de chat criada/verificada com o ID: $chatId');
  }

  Future<void> _registerLike(String likedUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    final likeData = {
      'likerUid': currentUser.uid,
      'likedUid': likedUserId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance.collection('likes').add(likeData);
    await _createChatRoom(likedUserId);
  }

  @override
  void didChangeDependencies() { super.didChangeDependencies(); _precacheNextImage(); }
  
  void _precacheNextImage() {
    if (!_isLoading && _currentIndex + 1 < _users.length) {
      // Ajustado para buscar 'profileImageUrl' do mapa dinâmico
      final nextUserImage = _users[_currentIndex + 1]['profileImageUrl'] as String?;
      if (nextUserImage != null && nextUserImage.isNotEmpty) {
        final imageProvider = nextUserImage.startsWith('http')
            ? NetworkImage(nextUserImage)
            : AssetImage(nextUserImage) as ImageProvider;
        precacheImage(imageProvider, context);
      }
    }
  }
  
  void _resetPosition() { 
    setState(() { 
      _position = Offset.zero; 
      _rotation = 0; 
      _showIcon = false; 
      // Ajustado para usar o tamanho da lista _users
      if (_currentIndex < _users.length - 1) { 
        _currentIndex++; 
      } else { 
        _currentIndex = 0; 
      } 
    }); 
    _precacheNextImage(); 
  }

  void _onPanUpdate(DragUpdateDetails details) { setState(() { _position += details.delta; _rotation = 0.002 * _position.dx; }); }
  
  void _onPanEnd(DragEndDetails details) { 
    final screenWidth = MediaQuery.of(context).size.width; 
    final threshold = screenWidth * 0.3; 
    if (_position.dx > threshold) { 
      _triggerSwipe(direction: 'right'); 
    } else if (_position.dx < -threshold) { 
      _triggerSwipe(direction: 'left'); 
    } else { 
      setState(() { _position = Offset.zero; _rotation = 0; }); 
    } 
  }

  Future<void> _navigateToEditProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { return; }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted && doc.exists) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProfileScreen(userData: doc.data())),
        );
      }
    } catch (e) { print(e); }
  }

  void _triggerSwipe({required String direction}) {
    // Adicionada verificação para evitar erro se a lista estiver vazia
    if (_users.isEmpty) return;

    final size = MediaQuery.of(context).size;
    Offset endOffset;
    String? icon;

    switch (direction) {
      case 'left':
        endOffset = Offset(-size.width, 0);
        icon = 'clear';
        break;
      case 'right': // Ação de Like/Match
        endOffset = Offset(size.width, 0);
        icon = 'star';
        _notificationService.showNotification('Novo Match! 💘', 'Uau, você acabou de registrar um Match!');
        // Ajustado para pegar o 'uid' do mapa dinâmico _users
        final likedUserId = _users[_currentIndex]['uid'] as String;
        _registerLike(likedUserId);
        break;
      case 'up':
        endOffset = Offset(0, -size.height);
        icon = 'favorite';
        break;
      default:
        endOffset = Offset.zero;
    }

    setState(() { _showIcon = true; _activeIcon = icon; });
    _animation = Tween<Offset>(begin: _position, end: endOffset).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward(from: 0);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const SizedBox(height: 10),
                  ),
                  const Column(
                    children: [
                      Text("Explorar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("São Paulo, SP", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    child: const Icon(Icons.tune, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              // Lógica condicional para mostrar o loading ou os cards
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                  ? const Center(child: Text("Nenhum perfil para mostrar."))
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_controller.isDismissed && _currentIndex + 1 < _users.length)
                          _buildCard(_users[_currentIndex + 1]),
                        GestureDetector(
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: Transform.translate(
                            offset: _position,
                            child: Transform.rotate(
                              angle: _rotation,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Garante que o índice não estoure se a lista estiver carregando
                                  if (_users.isNotEmpty) _buildCard(_users[_currentIndex]),
                                  _buildAnimatedIcon(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.clear, Colors.orange, () => _triggerSwipe(direction: 'left')),
                  _buildActionButton(Icons.favorite, Colors.pink, () => _triggerSwipe(direction: 'up'), size: 64),
                  _buildActionButton(Icons.star, Colors.purple, () => _triggerSwipe(direction: 'right')),
                ],
              ),
            ),
            Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.redAccent),
                  const Icon(Icons.favorite, color: Colors.pink),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatListScreen()),
                      );
                    },
                    child: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: _navigateToEditProfile,
                    child: const Icon(Icons.person, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    IconData? icon;
    Color color;
    switch (_activeIcon) {
      case 'clear': icon = Icons.clear; color = Colors.orange; break;
      case 'star': icon = Icons.star; color = Colors.purple; break;
      case 'favorite': icon = Icons.favorite; color = Colors.pink; break;
      default: return const SizedBox();
    }
    return AnimatedOpacity(opacity: _showIcon ? 1 : 0, duration: const Duration(milliseconds: 200), child: Center(child: Icon(icon, size: 100, color: color.withOpacity(0.8))));
  }

  // A assinatura do método foi alterada para aceitar dados dinâmicos
  Widget _buildCard(Map<String, dynamic> user) {
    // Lógica para calcular a idade a partir do Timestamp do Firebase
    String age = '';
    if (user['birthDate'] is Timestamp) {
      final birthDate = (user['birthDate'] as Timestamp).toDate();
      final today = DateTime.now();
      age = (today.year - birthDate.year - ((today.month > birthDate.month || (today.month == birthDate.month && today.day >= birthDate.day)) ? 0 : 1)).toString();
    }

    final imageUrl = user['profileImageUrl'] as String?;

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.6,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Lida com imagens da internet (http) ou assets locais
        image: imageUrl != null && imageUrl.isNotEmpty
          ? DecorationImage(
              image: imageUrl.startsWith('http') 
                ? NetworkImage(imageUrl) 
                : AssetImage(imageUrl) as ImageProvider,
              fit: BoxFit.cover,
            )
          : null,
        color: imageUrl == null || imageUrl.isEmpty ? Colors.grey.shade300 : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withAlpha(178), Colors.transparent]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Usa os dados dinâmicos do Firebase
                  "${user['firstName'] ?? ''}, $age", 
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                // Exemplo de como acessar outro campo, se existir
                if (user['profession'] != null)
                  Text(user['profession'] as String, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed, {double size = 48}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}