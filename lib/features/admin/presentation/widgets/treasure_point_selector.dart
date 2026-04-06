import 'package:flutter/material.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

class TreasurePointSelector extends StatelessWidget {
  final List<TreasurePoint> availablePoints;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  const TreasurePointSelector({
    super.key,
    required this.availablePoints,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (availablePoints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 18),
            const SizedBox(width: 8),
            Text(
              'Linked Treasure Points',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: availablePoints.map((point) {
            final isSelected = selectedIds.contains(point.id);
            return FilterChip(
              label: Text(point.name),
              selected: isSelected,
              onSelected: (selected) {
                final updated = List<String>.from(selectedIds);
                if (selected) {
                  updated.add(point.id);
                } else {
                  updated.remove(point.id);
                }
                onChanged(updated);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
