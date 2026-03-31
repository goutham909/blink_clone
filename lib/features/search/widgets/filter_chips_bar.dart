import 'package:flutter/material.dart';

import '../../../core/constants.dart';

class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final chips = [
      (icon: Icons.tune, label: 'Filters'),
      (icon: Icons.swap_vert, label: 'Sort'),
      (icon: null, label: 'Brand'),
      (icon: null, label: 'Flavour'),
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
            onPressed: () {},
          );
        },
      ),
    );
  }
}
