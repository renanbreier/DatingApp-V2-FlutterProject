import 'package:flutter/material.dart';

class VerificationKeyboard extends StatelessWidget {
  final void Function(String) onTap;

  const VerificationKeyboard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '', '0', 'del',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        if (key == '') return const SizedBox.shrink();

        return InkWell(
          onTap: () => onTap(key),
          child: SizedBox(
            height: 60,
            width: 60,
            child: Center(
              child: key == 'del'
                  ? const Icon(Icons.backspace_outlined, size: 24)
                  : Text(key, style: const TextStyle(fontSize: 22)),
            ),
          ),
        );
      },
    );
  }
}