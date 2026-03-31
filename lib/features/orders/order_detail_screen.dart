import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/order_models.dart';
import '../../providers/providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    OrderRecord? found;
    for (final o in orders) {
      if (o.id == orderId) found = o;
    }

    if (found == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Order not found')),
      );
    }

    final o = found;

    return Scaffold(
      key: Key('screen_order_$orderId'),
      appBar: AppBar(title: Text(o.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Placed ${_format(o.placedAt)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(o.addressSummary),
          const SizedBox(height: 8),
          Text('Payment: ${o.paymentLabel}'),
          const SizedBox(height: 16),
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...OrderStatus.values.map(
            (s) => ListTile(
              dense: true,
              leading: Icon(
                _icon(s),
                color: s.index <= o.status.index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              title: Text(_label(s)),
            ),
          ),
          const Divider(height: 32),
          Text(
            'Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...o.lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text('${l.product.name} × ${l.quantity}')),
                  Text('₹${l.lineTotal}'),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('₹${o.subtotal}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery'),
              Text('₹${o.deliveryFee}'),
            ],
          ),
          const SizedBox(height: 8),
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
                '₹${o.total}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _format(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  static String _label(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.packing:
        return 'Packing';
      case OrderStatus.onWay:
        return 'On the way';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  static IconData _icon(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed:
        return Icons.check_circle_outline;
      case OrderStatus.packing:
        return Icons.inventory_2_outlined;
      case OrderStatus.onWay:
        return Icons.delivery_dining_outlined;
      case OrderStatus.delivered:
        return Icons.done_all;
    }
  }
}
