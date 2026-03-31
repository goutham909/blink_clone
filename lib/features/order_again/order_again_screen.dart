import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';

class OrderAgainScreen extends ConsumerWidget {
  const OrderAgainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      key: const Key('screen_order_again'),
      appBar: AppBar(
        title: const Text('Order again'),
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (catalog) {
          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No past orders yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Place an order from home and it will show up here for quick reorder.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
          final byId = catalog.productById;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final o = orders[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              o.id,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.pushNamed(
                              'orderDetail',
                              pathParameters: {'orderId': o.id},
                            ),
                            child: const Text('Details'),
                          ),
                        ],
                      ),
                      Text(
                        '${o.lines.length} items · ₹${o.total}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () {
                          for (final line in o.lines) {
                            if (byId[line.product.id]?.inStock == true) {
                              for (var k = 0; k < line.quantity; k++) {
                                ref.read(cartProvider.notifier).addOne(line.product.id);
                              }
                            }
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
                          context.pushNamed('cart');
                        },
                        child: const Text('Reorder'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
