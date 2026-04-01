import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/product.dart';
import '../../providers/providers.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(wishlistProvider);
    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      key: const Key('screen_wishlist'),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Your wishlist'),
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (catalog) {
          if (ids.isEmpty) {
            return Center(
              child: Text(
                'Tap the heart on a product to save it here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            );
          }
          final byId = catalog.productById;
          final products = ids.map((id) => byId[id]).whereType<Product>().toList();
          if (products.isEmpty) {
            return const Center(child: Text('Saved items are no longer in the catalog.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.52,
            ),
            itemCount: products.length,
            itemBuilder: (context, i) {
              return ProductCard(
                product: products[i],
                width: double.infinity,
                layout: ProductCardLayout.grid,
              );
            },
          );
        },
      ),
    );
  }
}
