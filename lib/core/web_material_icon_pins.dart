import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Flutter web **tree-shakes** the Material Icons font. Icons returned only from
/// helpers like [iconForCategoryName] may be stripped, so glyphs render blank
/// (or as wrong shapes) in release/profile web builds.
///
/// This layer keeps those code points in the compiled font by referencing each
/// [IconData] in the widget tree (off-screen). Safe no-op on non-web platforms.
class WebMaterialIconPinsLayer extends StatelessWidget {
  const WebMaterialIconPinsLayer({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    return Positioned(
      left: -512,
      top: -512,
      child: IgnorePointer(
        child: SizedBox(
          width: 1,
          height: 1,
          child: OverflowBox(
            maxWidth: 400,
            maxHeight: 400,
            alignment: Alignment.topLeft,
            child: Wrap(
              spacing: 0,
              runSpacing: 0,
              children: [
              // Category chips (iconForCategoryName)
              Icon(Icons.apps_outlined, size: 14),
              Icon(Icons.wb_sunny_outlined, size: 14),
              Icon(Icons.devices_outlined, size: 14),
              Icon(Icons.spa_outlined, size: 14),
              Icon(Icons.medication_outlined, size: 14),
              Icon(Icons.local_drink_outlined, size: 14),
              Icon(Icons.fastfood_outlined, size: 14),
              Icon(Icons.local_bar_outlined, size: 14),
              Icon(Icons.kitchen_outlined, size: 14),
              Icon(Icons.light_outlined, size: 14),
              Icon(Icons.child_care_outlined, size: 14),
              Icon(Icons.card_giftcard_outlined, size: 14),
              Icon(Icons.shopping_cart_outlined, size: 14),
              // Bottom nav (NavigationBar + web font retention)
              Icon(Icons.home_outlined, size: 14),
              Icon(Icons.home_filled, size: 14),
              Icon(Icons.replay_outlined, size: 14),
              Icon(Icons.replay_rounded, size: 14),
              Icon(Icons.grid_view_outlined, size: 14),
              Icon(Icons.grid_view_rounded, size: 14),
              Icon(Icons.print_outlined, size: 14),
              Icon(Icons.print_rounded, size: 14),
              // Other screens still use shopping bag icons
              Icon(Icons.shopping_bag_outlined, size: 14),
              Icon(Icons.shopping_bag_rounded, size: 14),
              // CatalogImage placeholders
              Icon(Icons.bakery_dining_outlined, size: 14),
              Icon(Icons.inventory_2_outlined, size: 14),
              Icon(Icons.bed_outlined, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
