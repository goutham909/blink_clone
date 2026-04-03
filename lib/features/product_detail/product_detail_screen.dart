import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../widgets/catalog_image.dart';
import '../../widgets/quantity_stepper.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(catalogProvider);
    final inWishlist = ref.watch(wishlistProvider).contains(productId);

    return catalogAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (catalog) {
        final p = catalog.productById[productId];
        if (p == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Product not found')),
          );
        }
        final scheme = Theme.of(context).colorScheme;
        final discount = p.discountPercent;

        return Scaffold(
          key: Key('screen_product_$productId'),
          appBar: AppBar(
            title: Semantics(
              label: 'product_title_$productId',
              child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            actions: [
              IconButton(
                tooltip: inWishlist ? 'Remove from wishlist' : 'Add to wishlist',
                onPressed: () => ref.read(wishlistProvider.notifier).toggle(p.id),
                icon: Icon(inWishlist ? Icons.favorite : Icons.favorite_border),
                color: inWishlist ? Colors.redAccent : null,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CatalogImage(
                imageRef: p.imageRef,
                imageHint: p.imageHint,
                accent: scheme.primary,
                height: 220,
                borderRadius: BorderRadius.circular(16),
                fit: BoxFit.cover,
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
