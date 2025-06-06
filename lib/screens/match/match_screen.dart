import 'package:datingapp/screens/chat_list/chat_list_screen.dart';
import 'package:datingapp/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with SingleTickerProviderStateMixin {
  final List<Map<String, String>> users = [
    {
      'name': 'Peter Parker',
      'age': '23',
      'profession': 'Desenvolvedor',
      'image': 'lib/assets/users/user_1.jpg'
    },
    {
      'name': 'Camila Alves',
      'age': '22',
      'profession': 'Modelo',
      'image': 'lib/assets/users/user_2.jpg'
    },
    {
      'name': 'Tiago Pinheiro',
      'age': '29',
      'profession': 'Designer',
      'image': 'lib/assets/users/user_3.jpg'
    },
    {
      'name': 'Larissa Silva',
      'age': '26',
      'profession': 'Fotografa',
      'image': 'lib/assets/users/user_4.jpg'
    },
  ];

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _controller.addListener(() {
      setState(() {
        _position = _animation.value;
        _rotation = 0.002 * _position.dx;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _resetPosition();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheNextImage();
  }

  void _precacheNextImage() {
    if (_currentIndex + 1 < users.length) {
      precacheImage(AssetImage(users[_currentIndex + 1]['image']!), context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetPosition() {
    setState(() {
      _position = Offset.zero;
      _rotation = 0;
      _showIcon = false;
      if (_currentIndex < users.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
    _precacheNextImage();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
      _rotation = 0.002 * _position.dx;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_position.dx > threshold) {
      _triggerSwipe(direction: 'right');
    } else if (_position.dx < -threshold) {
      _triggerSwipe(direction: 'left');
    } else {
      setState(() {
        _position = Offset.zero;
        _rotation = 0;
      });
    }
  }

  void _triggerSwipe({required String direction}) {
    final size = MediaQuery.of(context).size;
    Offset endOffset;
    String? icon;

    switch (direction) {
      case 'left':
        endOffset = Offset(-size.width, 0);
        icon = 'clear';
        break;
      case 'right':
        endOffset = Offset(size.width, 0);
        icon = 'star';
        break;
      case 'up':
        endOffset = Offset(0, -size.height);
        icon = 'favorite';
        break;
      default:
        endOffset = Offset.zero;
    }

    setState(() {
      _showIcon = true;
      _activeIcon = icon;
    });

    _animation = Tween<Offset>(
      begin: _position,
      end: endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(from: 0);
  }

  Widget _buildAnimatedIcon() {
    IconData? icon;
    Color color;

    switch (_activeIcon) {
      case 'clear':
        icon = Icons.clear;
        color = Colors.orange;
        break;
      case 'star':
        icon = Icons.star;
        color = Colors.purple;
        break;
      case 'favorite':
        icon = Icons.favorite;
        color = Colors.pink;
        break;
      default:
        return const SizedBox();
    }

    return AnimatedOpacity(
      opacity: _showIcon ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: Center(
        child: Icon(icon, size: 100, color: color.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildCard(Map<String, String> user) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.6,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(user['image']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withAlpha(178), Colors.transparent],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${user['name']}, ${user['age']}",
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user['profession']!, style: const TextStyle(color: Colors.white70)),
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
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
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
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Column(
                    children: const [
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_controller.isDismissed && _currentIndex + 1 < users.length)
                    _buildCard(users[_currentIndex + 1]),
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
                            _buildCard(users[_currentIndex]),
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
                      onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.person_outline, color: Colors.black),
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