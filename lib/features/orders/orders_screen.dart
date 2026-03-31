import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      key: const Key('screen_orders'),
      appBar: AppBar(title: const Text('Orders')),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final o = orders[i];
                return Card(
                  child: ListTile(
                    key: Key('order_tile_${o.id}'),
                    title: Text(o.id),
                    subtitle: Text(
                      '${o.lines.length} items · ₹${o.total}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.pushNamed(
                      'orderDetail',
                      pathParameters: {'orderId': o.id},
                    ),
                  ),
                );
              },
            ),
    );
  }
}
