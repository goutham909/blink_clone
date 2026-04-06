import 'package:flutter/material.dart';

import '../../../core/category_icons.dart';
import '../../../data/models/category_chip.dart';
import '../home_festival_theme.dart';

/// Blinkit-style horizontal category row: line-art icon + label, scrollable,
/// thick underline for the active tab. Uses bundled PNGs when available.
class HomeCategoryChipsRow extends StatelessWidget {
  const HomeCategoryChipsRow({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.visuals,
    required this.onSelected,
  });

  final List<CategoryChipData> categories;
  final String selectedId;
  final HomeFestivalVisuals visuals;
  final void Function(CategoryChipData chip) onSelected;

  @override
  Widget build(BuildContext context) {
    final v = visuals;
    if (categories.isEmpty) {
      return const SizedBox(height: 8);
    }

    return ColoredBox(
      color: v.stripBelowHeaderColor,
      child: SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 2),
          itemBuilder: (context, i) {
            final c = categories[i];
            final selected = c.id == selectedId;
            return _CategoryChip(
              data: c,
              selected: selected,
              visuals: v,
              onTap: () => onSelected(c),
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
    final pngPath = categoryChipPngAssetPath(data.iconName);
    final tint = v.categoryIconColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SizedBox(
            width: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (pngPath != null)
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
                          child: Image.asset(
                            pngPath,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) =>
                                _FallbackIconCircle(visuals: v, iconName: data.iconName, selected: selected),
                          ),
                        ),
                      )
                    else
                      _FallbackIconCircle(visuals: v, iconName: data.iconName, selected: selected),
                    if (data.badgeText != null)
                      Positioned(
                        top: -4,
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
                const SizedBox(height: 6),
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
                  height: 3,
                  width: selected ? 36 : 0,
                  decoration: BoxDecoration(
                    color: v.categoryCircleBorderSelected,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackIconCircle extends StatelessWidget {
  const _FallbackIconCircle({
    required this.visuals,
    required this.iconName,
    required this.selected,
  });

  final HomeFestivalVisuals visuals;
  final String iconName;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final v = visuals;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: v.categoryCircleFill,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? v.categoryCircleBorderSelected : Colors.transparent,
          width: selected ? 2 : 0,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconForCategoryName(iconName),
        size: 22,
        color: v.categoryIconColor,
      ),
    );
  }
}
