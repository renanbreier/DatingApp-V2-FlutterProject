import 'package:flutter/material.dart';

class NameInputFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const NameInputFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: firstNameController,
          decoration: const InputDecoration(
            labelText: "Nome",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: lastNameController,
          decoration: const InputDecoration(
            labelText: "Sobrenome",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}