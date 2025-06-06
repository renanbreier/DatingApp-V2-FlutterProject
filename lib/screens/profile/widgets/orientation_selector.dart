import 'package:flutter/material.dart';

class OrientationSelector extends StatelessWidget {
  final String? selectedOrientation;
  final Function(String?) onChanged;

  const OrientationSelector({
    super.key,
    required this.selectedOrientation,
    required this.onChanged,
  });

  final List<String> _orientations = const [
    'Heterossexual',
    'Homossexual',
    'Bissexual',
    'Pansexual',
    'Assexual',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Selecione sua orientação sexual:", style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: _orientations.map((orientation) {
            final isSelected = selectedOrientation == orientation;
            return FilterChip(
              label: Text(orientation),
              selected: isSelected,
              selectedColor: Colors.redAccent.shade100,
              onSelected: (selected) => onChanged(selected ? orientation : null),
            );
          }).toList(),
        ),
      ],
    );
  }
}