import 'package:flutter/material.dart';

import '../../../core/constants.dart';

class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({
    super.key,
    required this.sortLabel,
    required this.onFiltersTap,
    required this.onSortTap,
    required this.onBrandTap,
    required this.onFlavourTap,
  });

  final String sortLabel;
  final VoidCallback onFiltersTap;
  final VoidCallback onSortTap;
  final VoidCallback onBrandTap;
  final VoidCallback onFlavourTap;

  @override
  Widget build(BuildContext context) {
    final chips = <({IconData? icon, String label, VoidCallback onPressed})>[
      (icon: Icons.tune, label: 'Filters', onPressed: onFiltersTap),
      (icon: Icons.swap_vert, label: sortLabel, onPressed: onSortTap),
      (icon: null, label: 'Brand', onPressed: onBrandTap),
      (icon: null, label: 'Flavour', onPressed: onFlavourTap),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = chips[i];
          return ActionChip(
            avatar: c.icon != null
                ? Icon(c.icon, size: 18, color: Colors.white70)
                : null,
            label: Text(c.label),
            labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
            backgroundColor: kBlinkDarkSurface,
            side: const BorderSide(color: Colors.white24),
            onPressed: c.onPressed,
          );
        },
      ),
    );
  }
}
