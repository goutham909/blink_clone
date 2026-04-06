import 'package:flutter/material.dart';

/// Blinkit-style **transparent mask** PNGs (`assets/category_icons/{name}.png`).
///
/// Each file must be a real PNG with alpha (line-art silhouette). JPEGs or other
/// opaque rasters break the category row’s `ColorFiltered` + `BlendMode.srcIn`
/// tinting (solid blocks). Tall images in a square slot also crop to a thin bar
/// under `BoxFit.contain`.
///
/// Add [iconName] keys here only after placing matching valid PNGs. Until then the
/// UI uses Material icons from [iconForCategoryName].
const _categoryChipPngNames = <String>{
  // e.g. 'all', 'summer', … once assets/category_icons/*.png are true mask PNGs
};

String? categoryChipPngAssetPath(String iconName) {
  if (!_categoryChipPngNames.contains(iconName)) return null;
  return 'assets/category_icons/$iconName.png';
}

IconData iconForCategoryName(String name) {
  switch (name) {
    case 'summer':
      return Icons.wb_sunny_outlined;
    case 'electronics':
      return Icons.devices_outlined;
    case 'beauty':
      return Icons.spa_outlined;
    case 'pharma':
      return Icons.medication_outlined;
    case 'dairy':
      return Icons.local_drink_outlined;
    case 'snacks':
      return Icons.fastfood_outlined;
    case 'beverage':
      return Icons.local_bar_outlined;
    case 'kitchen':
      return Icons.kitchen_outlined;
    case 'decor':
      return Icons.light_outlined;
    case 'kids':
      return Icons.child_care_outlined;
    case 'gifting':
      return Icons.card_giftcard_outlined;
    case 'imported':
      return Icons.shopping_cart_outlined;
    case 'all':
    default:
      return Icons.apps_outlined;
  }
}
