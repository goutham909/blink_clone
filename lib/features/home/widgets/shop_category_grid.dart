import 'package:flutter/material.dart';

import '../../../data/models/shop_category_tile.dart';
import '../../../widgets/catalog_image.dart';

/// Blinkit-style square category cells: soft tile background, product-style photo, 2-line label.
class ShopCategoryGrid extends StatelessWidget {
  const ShopCategoryGrid({
    super.key,
    required this.tiles,
    required this.onTileTap,
    required this.tileBackground,
  });

  final List<ShopCategoryTile> tiles;
  final void Function(ShopCategoryTile tile) onTileTap;
  final Color tileBackground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (tiles.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final n = (w / 76).floor().clamp(4, 5);
        const gap = 10.0;
        const hPad = 12.0;
        final cellW = (w - hPad * 2 - gap * (n - 1)) / n;
        const labelBlock = 34.0;
        final rowHeight = cellW + labelBlock;

        return Padding(
          padding: const EdgeInsets.fromLTRB(hPad, 12, hPad, 10),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: n,
              mainAxisSpacing: gap,
              crossAxisSpacing: gap,
              mainAxisExtent: rowHeight,
            ),
            itemBuilder: (context, i) {
              final t = tiles[i];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTileTap(t),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: cellW,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: tileBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: CatalogImage(
                              imageRef: t.imageRef,
                              imageHint: 'kitchen',
                              accent: scheme.primary,
                              height: cellW - 12,
                              borderRadius: BorderRadius.circular(8),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10.5,
                              height: 1.15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF424242),
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
