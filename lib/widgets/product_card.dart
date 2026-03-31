import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/product.dart';
import 'product_image_placeholder.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.width = 132,
    this.dense = false,
  });

  final Product product;
  final double width;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final discount = product.discountPercent;

    return Semantics(
      label: 'product_card_${product.id}',
      button: true,
      child: InkWell(
        key: Key('product_card_${product.id}'),
        onTap: () => context.pushNamed('product', pathParameters: {'id': product.id}),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ProductImagePlaceholder(
                    imageHint: product.imageHint,
                    accent: scheme.primary,
                    height: dense ? 100 : 120,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  if (discount > 0)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$discount% OFF',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.onSecondaryContainer,
                              ),
                        ),
                      ),
                    ),
                  if (!product.inStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
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
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product.unit,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.outline,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    '₹${product.salePrice}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (product.mrp > product.salePrice) ...[
                    const SizedBox(width: 6),
                    Text(
                      '₹${product.mrp}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: scheme.outline,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
