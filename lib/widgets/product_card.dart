import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../data/models/product.dart';
import '../providers/providers.dart';
import 'product_image_placeholder.dart';

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
    final discount = product.discountPercent;
    final cartQty = ref.watch(cartProvider)[product.id] ?? 0;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ProductImagePlaceholder(
                      imageHint: product.imageHint,
                      accent: scheme.primary,
                      height: _imageHeight,
                      borderRadius: BorderRadius.circular(12),
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
                                color: const Color(0xFFE11D48),
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
                                color: const Color(0xFFE11D48),
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
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border, size: 18, color: Colors.white70),
                      ),
                    ),
                    if (!product.inStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
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
                        child: GestureDetector(
                          onTap: () => ref.read(cartProvider.notifier).addOne(product.id),
                          child: cartQty > 0
                              ? Container(
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
                                )
                              : Container(
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
                        ),
                      ),
                  ],
                ),
                if (product.inStock && product.optionsCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${product.optionsCount} options',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: kBlinkGreen,
                            fontSize: 10,
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
                          border: Border.all(color: kBlinkGreen, width: 1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: kBlinkGreen,
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
                              color: scheme.outline,
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
                            color: scheme.outline,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 12, color: kBlinkGreen),
                    const SizedBox(width: 2),
                    Text(
                      '${product.deliveryMinutes} MINS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: kBlinkGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                if (product.isLowStock) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Only ${product.stockLeft} left',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.orangeAccent,
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
                            fontWeight: FontWeight.bold,
                            fontSize: layout == ProductCardLayout.grid ? 13 : 14,
                          ),
                    ),
                    if (discount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '$discount% OFF',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.lightBlueAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
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
                          color: scheme.outline,
                          fontSize: 10,
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
