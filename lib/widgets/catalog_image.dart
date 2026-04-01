import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Resolves `asset:catalog_images/foo.jpg` to a Flutter [Image.asset] path.
String? catalogAssetPathFromRef(String? ref) {
  final r = ref?.trim();
  if (r == null || !r.startsWith('asset:')) return null;
  final path = r.substring('asset:'.length);
  return path.startsWith('assets/') ? path : 'assets/$path';
}

/// Renders a catalog [imageRef]: `https://...` uses the network; `asset:catalog_images/foo.jpg` uses [Image.asset].
class CatalogImage extends StatelessWidget {
  const CatalogImage({
    super.key,
    required this.imageRef,
    required this.imageHint,
    required this.accent,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.fit = BoxFit.cover,
  });

  final String? imageRef;
  final String imageHint;
  final Color accent;
  final double? height;
  final BorderRadiusGeometry borderRadius;
  final BoxFit fit;

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

  Widget _gradientPlaceholder(double h) {
    return Container(
      height: h,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.22),
            kBlinkDarkCard,
            accent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Icon(
        _iconForHint(),
        size: h * 0.38,
        color: accent.withValues(alpha: 0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = height ?? 120.0;
    final raw = imageRef?.trim();
    if (raw == null || raw.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: _gradientPlaceholder(h),
      );
    }

    if (raw.startsWith('asset:')) {
      final path = raw.substring('asset:'.length);
      final assetPath = path.startsWith('assets/') ? path : 'assets/$path';
      return ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          height: h,
          width: double.infinity,
          child: Image.asset(
            assetPath,
            fit: fit,
            errorBuilder: (_, __, ___) => _gradientPlaceholder(h),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: Image.network(
          raw,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: h,
              alignment: Alignment.center,
              color: kBlinkDarkCard,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _gradientPlaceholder(h),
        ),
      ),
    );
  }
}
