import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../data/models/product.dart';
import '../../../providers/providers.dart';
import '../../../widgets/product_card.dart';

/// Dark “Blinkit category” shelf: title + horizontal product rail + see-all row.
class HomeCategoryFeed extends ConsumerWidget {
  const HomeCategoryFeed({
    super.key,
    required this.title,
    this.subtitle,
    required this.products,
    required this.categoryId,
    this.bottomPadding = 24,
  });

  final String title;
  final String? subtitle;
  final List<Product> products;
  final String categoryId;
  final double bottomPadding;

  static ThemeData _shelfTheme(BuildContext context) {
    final base = Theme.of(context);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: base.textTheme,
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF2C2C2C),
        onSurface: Colors.white,
        outline: Colors.white54,
        primary: kBlinkGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideSensitive = ref.watch(hideSensitiveProvider);

    return Theme(
      data: _shelfTheme(context),
      child: ColoredBox(
        color: kBlinkScreenBg,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 0, bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (products.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Text(
                    hideSensitive && categoryId == 'cat_pharma'
                        ? 'This aisle is hidden while “Hide sensitive” is on.'
                        : 'No products in this aisle yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                )
              else
                SizedBox(
                  height: 288,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    primary: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ProductCard(
                          product: products[i],
                          width: 156,
                          layout: ProductCardLayout.rail,
                        ),
                      );
                    },
                  ),
                ),
              if (products.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Material(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => context.pushNamed(
                        'search',
                        queryParameters: {'category': categoryId},
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            _ThumbStack(products: products),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'See all products',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbStack extends StatelessWidget {
  const _ThumbStack({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hints = products.take(3).map((p) => p.imageHint).toList();
    while (hints.length < 3) {
      hints.add('misc');
    }
    const size = 36.0;
    return SizedBox(
      width: size + 18,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            child: _MiniThumb(hint: hints[0], accent: scheme.primary, angle: -0.08),
          ),
          Positioned(
            left: 10,
            child: _MiniThumb(hint: hints[1], accent: scheme.secondary, angle: 0),
          ),
          Positioned(
            left: 20,
            child: _MiniThumb(hint: hints[2], accent: scheme.tertiary, angle: 0.06),
          ),
        ],
      ),
    );
  }
}

class _MiniThumb extends StatelessWidget {
  const _MiniThumb({
    required this.hint,
    required this.accent,
    required this.angle,
  });

  final String hint;
  final Color accent;
  final double angle;

  IconData _icon() {
    switch (hint) {
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
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
          gradient: LinearGradient(
            colors: [
              accent.withValues(alpha: 0.35),
              const Color(0xFF1E1E1E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(_icon(), size: 16, color: Colors.white70),
      ),
    );
  }
}
