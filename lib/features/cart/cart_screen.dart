import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../widgets/quantity_stepper.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final catalogAsync = ref.watch(catalogProvider);
    final totals = ref.watch(cartTotalsProvider);

    return Scaffold(
      key: const Key('screen_cart'),
      appBar: AppBar(title: const Text('Cart')),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (catalog) {
          if (cart.isEmpty || totals.itemCount == 0) {
            return const Center(
              child: Text('Your cart is empty'),
            );
          }
          final byId = catalog.productById;
          final lines = cart.entries
              .map((e) => (id: e.key, qty: e.value, product: byId[e.key]))
              .where((t) => t.product != null && t.product!.inStock)
              .toList();

          const deliveryFee = 25;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lines.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, i) {
                    final row = lines[i];
                    final p = row.product!;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                label: 'cart_line_title_${p.id}',
                                child: Text(
                                  p.name,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.unit,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${p.salePrice} × ${row.qty}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        QuantityStepper(productId: p.id, enabled: true),
                      ],
                    );
                  },
                ),
              ),
              Material(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('₹${totals.subtotal}'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery (mock)'),
                          Text('₹$deliveryFee'),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '₹${totals.subtotal + deliveryFee}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: const Key('checkout_cta'),
                          onPressed: () => context.pushNamed('checkout'),
                          child: const Text('Proceed to checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
