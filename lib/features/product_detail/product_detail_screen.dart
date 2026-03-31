import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../widgets/product_image_placeholder.dart';
import '../../widgets/quantity_stepper.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(catalogRepositoryProvider);

    return FutureBuilder(
      future: repo.getProduct(productId),
      builder: (context, snap) {
        if (!snap.hasData || snap.data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Product not found')),
          );
        }
        final p = snap.data!;
        final scheme = Theme.of(context).colorScheme;
        final discount = p.discountPercent;

        return Scaffold(
          key: Key('screen_product_$productId'),
          appBar: AppBar(
            title: Semantics(
              label: 'product_title_$productId',
              child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProductImagePlaceholder(
                imageHint: p.imageHint,
                accent: scheme.primary,
                height: 220,
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(height: 16),
              Text(
                p.unit,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.outline,
                    ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${p.salePrice}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (p.mrp > p.salePrice) ...[
                    const SizedBox(width: 10),
                    Text(
                      '₹${p.mrp}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: scheme.outline,
                          ),
                    ),
                    const SizedBox(width: 10),
                    if (discount > 0)
                      Chip(
                        label: Text('$discount% off'),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Synthetic catalog item for testing. Not affiliated with any retailer.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.outline,
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: QuantityStepper(productId: p.id, enabled: p.inStock),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
