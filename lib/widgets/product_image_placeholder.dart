import 'package:flutter/material.dart';

class ProductImagePlaceholder extends StatelessWidget {
  const ProductImagePlaceholder({
    super.key,
    required this.imageHint,
    required this.accent,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final String imageHint;
  final Color accent;
  final double? height;
  final BorderRadiusGeometry borderRadius;

  IconData _iconForHint() {
    switch (imageHint) {
      case 'dairy':
        return Icons.local_drink_outlined;
      case 'bakery':
        return Icons.bakery_dining_outlined;
      case 'snacks':
        return Icons.fastfood_outlined;
      case 'beverage':
        return Icons.local_bar_outlined;
      case 'kitchen':
        return Icons.kitchen_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accent.withValues(alpha: 0.15),
              accent.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          _iconForHint(),
          size: height != null ? height! * 0.35 : 40,
          color: accent.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
