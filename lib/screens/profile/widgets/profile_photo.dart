import 'package:flutter/material.dart';

class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('lib/assets/profile.jpg'),
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFE94057),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
        ),
      ],
    );
  }
}