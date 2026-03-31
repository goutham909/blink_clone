import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/order_models.dart';
import '../../providers/providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _line1 = TextEditingController(text: '12 Sample Street');
  final _city = TextEditingController(text: 'Bengaluru');
  String _payment = 'Cash on delivery';

  @override
  void dispose() {
    _line1.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogProvider);
    final cart = ref.watch(cartProvider);
    final totals = ref.watch(cartTotalsProvider);
    const deliveryFee = 25;

    return Scaffold(
      key: const Key('screen_checkout'),
      appBar: AppBar(title: const Text('Checkout')),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (catalog) {
          if (cart.isEmpty || totals.itemCount == 0) {
            return const Center(child: Text('Cart is empty'));
          }

          final byId = catalog.productById;
          final lines = <OrderLine>[];
          for (final e in cart.entries) {
            final p = byId[e.key];
            if (p != null && p.inStock) {
              lines.add(OrderLine(product: p, quantity: e.value));
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Delivery address',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('checkout_address_line'),
                controller: _line1,
                decoration: const InputDecoration(
                  labelText: 'Address line',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('checkout_city'),
                controller: _city,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment (mock)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...[
                'Cash on delivery',
                'UPI (mock)',
                'Card (mock)',
              ].map(
                (m) => RadioListTile<String>(
                  key: Key('payment_$m'),
                  value: m,
                  groupValue: _payment,
                  onChanged: (v) => setState(() => _payment = v ?? _payment),
                  title: Text(m),
                ),
              ),
              const Divider(height: 32),
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
                  const Text('Delivery'),
                  Text('₹$deliveryFee'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payable',
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
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('place_order_cta'),
                onPressed: () {
                  final id = 'ord_${DateTime.now().millisecondsSinceEpoch}';
                  final order = OrderRecord(
                    id: id,
                    placedAt: DateTime.now(),
                    lines: lines,
                    deliveryFee: deliveryFee,
                    addressSummary: '${_line1.text}, ${_city.text}',
                    paymentLabel: _payment,
                    status: OrderStatus.placed,
                  );
                  ref.read(ordersProvider.notifier).add(order);
                  ref.read(cartProvider.notifier).clear();
                  context.pushReplacementNamed(
                    'orderDetail',
                    pathParameters: {'orderId': id},
                  );
                },
                child: const Text('Place order'),
              ),
            ],
          );
        },
      ),
    );
  }
}
