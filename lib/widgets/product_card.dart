import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../data/models/product.dart';
import '../providers/providers.dart';
import 'catalog_image.dart';

enum ProductCardLayout { rail, grid }

class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.width = 132,
    this.layout = ProductCardLayout.rail,
  });

  final Product product;
  final double width;
  final ProductCardLayout layout;

  double get _imageHeight => layout == ProductCardLayout.grid ? 96 : 120;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final discount = product.discountPercent;
    final cartQty = ref.watch(cartProvider)[product.id] ?? 0;
    final wishlist = ref.watch(wishlistProvider);
    final inWishlist = wishlist.contains(product.id);

    final metaColor = isDark ? kBlinkMutedOnDark : scheme.outline;
    final titleColor = isDark ? Colors.white : scheme.onSurface;
    final imgRadius = BorderRadius.circular(isDark ? 10 : 12);

    final tagBg = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE11D48);

    Widget addChip() {
      if (!product.inStock) return const SizedBox.shrink();
      void add() => ref.read(cartProvider.notifier).addOne(product.id);
      if (cartQty > 0) {
        return GestureDetector(
          onTap: add,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kBlinkGreen,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              '$cartQty',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }
      if (isDark) {
        return GestureDetector(
          onTap: add,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBlinkGreenOutline, width: 1.5),
            ),
            child: const Text(
              'ADD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
          ),
        );
      }
      return GestureDetector(
        onTap: add,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: kBlinkGreen,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: const Text(
            'ADD',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CatalogImage(
              imageRef: product.imageRef,
              imageHint: product.imageHint,
              accent: scheme.primary,
              height: _imageHeight,
              borderRadius: imgRadius,
              fit: BoxFit.cover,
            ),
            Positioned(
              left: 4,
              top: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.boughtEarlier)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Bought Earlier',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  if (layout == ProductCardLayout.rail && product.saveAmount > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Save ₹${product.saveAmount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    )
                  else if (discount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$discount% OFF',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            if (product.isAd)
              Positioned(
                left: 4,
                bottom: 28,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'Ad',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 9,
                        ),
                  ),
                ),
              ),
            Positioned(
              right: 2,
              top: 2,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () => ref.read(wishlistProvider.notifier).toggle(product.id),
                icon: Icon(
                  inWishlist ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: inWishlist ? Colors.redAccent : Colors.white70,
                ),
              ),
            ),
            if (!product.inStock)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: imgRadius,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Out of stock',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              )
            else
              Positioned(
                right: 6,
                bottom: 6,
                child: addChip(),
              ),
          ],
        ),
        if (product.inStock && product.optionsCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${product.optionsCount} options',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark ? kBlinkGreenOutline : kBlinkGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (product.isVegetarian)
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? kBlinkGreenOutline : kBlinkGreen, width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? kBlinkGreenOutline : kBlinkGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                product.unit,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: metaColor,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: layout == ProductCardLayout.grid ? 11 : 12,
                color: titleColor,
                height: 1.25,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.star, size: 12, color: Colors.amber.shade600),
            const SizedBox(width: 2),
            Text(
              '${product.rating.toStringAsFixed(1)} (${product.ratingCount})',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: metaColor,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.schedule, size: 12, color: isDark ? kBlinkGold : kBlinkGreen),
            const SizedBox(width: 2),
            Text(
              '${product.deliveryMinutes} MINS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark ? kBlinkGold : kBlinkGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
            ),
          ],
        ),
        if (product.isLowStock) ...[
          const SizedBox(height: 2),
          Text(
            'Only ${product.stockLeft} left',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFFFB74D),
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
          ),
        ],
        const Spacer(),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${product.salePrice}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: layout == ProductCardLayout.grid ? 13 : 15,
                    color: titleColor,
                  ),
            ),
            if (discount > 0) ...[
              const SizedBox(width: 6),
              Text(
                '$discount% OFF',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: kBlinkDiscountBlue,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ],
        ),
        if (product.mrp > product.salePrice)
          Text(
            'MRP ₹${product.mrp}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: metaColor,
                  fontSize: 10,
                ),
          ),
      ],
    );

    final padded = isDark
        ? Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBlinkRailCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: column,
          )
        : column;

    return Semantics(
      label: 'product_card_${product.id}',
      button: true,
      child: SizedBox(
        width: width,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: Key('product_card_${product.id}'),
            onTap: () => context.pushNamed('product', pathParameters: {'id': product.id}),
            borderRadius: BorderRadius.circular(12),
            child: padded,
          ),
        ),
      ),
    );
  }
}
