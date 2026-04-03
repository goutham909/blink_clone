import 'package:flutter/material.dart';

import '../../../core/category_icons.dart';
import '../../../data/models/category_chip.dart';
import '../home_festival_theme.dart';

/// Blinkit-style horizontal category row: small icon + label, scrollable, one row tall.
class HomeCategoryChipsRow extends StatefulWidget {
  const HomeCategoryChipsRow({
    super.key,
    required this.categories,
    required this.visuals,
    required this.onChipTap,
  });

  final List<CategoryChipData> categories;
  final HomeFestivalVisuals visuals;
  final void Function(CategoryChipData chip) onChipTap;

  @override
  State<HomeCategoryChipsRow> createState() => _HomeCategoryChipsRowState();
}

class _HomeCategoryChipsRowState extends State<HomeCategoryChipsRow> {
  String _selectedId = 'cat_all';

  @override
  Widget build(BuildContext context) {
    final v = widget.visuals;
    if (widget.categories.isEmpty) {
      return const SizedBox(height: 8);
    }

    return ColoredBox(
      color: v.stripBelowHeaderColor,
      child: SizedBox(
        height: 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          physics: const BouncingScrollPhysics(),
          itemCount: widget.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 4),
          itemBuilder: (context, i) {
            final c = widget.categories[i];
            final selected = c.id == _selectedId;
            return _CategoryChip(
              data: c,
              selected: selected,
              visuals: v,
              onTap: () {
                setState(() => _selectedId = c.id);
                widget.onChipTap(c);
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.data,
    required this.selected,
    required this.visuals,
    required this.onTap,
  });

  final CategoryChipData data;
  final bool selected;
  final HomeFestivalVisuals visuals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = visuals;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: v.categoryCircleFill,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? v.categoryCircleBorderSelected
                            : Colors.transparent,
                        width: selected ? 2 : 0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      iconForCategoryName(data.iconName),
                      size: 22,
                      color: v.categoryIconColor,
                    ),
                  ),
                  if (data.badgeText != null)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          data.badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: v.categoryLabelColor,
                      height: 1.1,
                    ),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: selected ? 28 : 0,
                decoration: BoxDecoration(
                  color: v.categoryCircleBorderSelected,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
