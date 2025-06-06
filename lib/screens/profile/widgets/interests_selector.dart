import 'package:flutter/material.dart';

class InterestsSelector extends StatelessWidget {
  final List<String> selectedInterests;
  final Function(List<String>) onChanged;

  const InterestsSelector({
    super.key,
    required this.selectedInterests,
    required this.onChanged,
  });

  final List<String> _interests = const [
    'Música', 'Viagens', 'Esportes', 'Filmes', 'Leitura',
    'Video game', 'Tecnologia', 'Pets', 'Arte', 'Culinária'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Selecione seus interesses:", style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: _interests.map((interest) {
            final isSelected = selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              selectedColor: Colors.redAccent.shade100,
              onSelected: (selected) {
                final updated = [...selectedInterests];
                selected ? updated.add(interest) : updated.remove(interest);
                onChanged(updated);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}