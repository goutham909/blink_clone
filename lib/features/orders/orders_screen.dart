import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/order_delivery_timeline.dart';
import '../../data/models/order_models.dart';
import '../../providers/providers.dart';

/// Order list with live ETA subtitles while any order is still in progress.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  Timer? _tick;

  bool _hasInFlight(List<OrderRecord> orders) {
    for (final o in orders) {
      if (o.status != OrderStatus.delivered) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);

    final needsTick = orders.isNotEmpty && _hasInFlight(orders);
    if (needsTick && _tick == null) {
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!needsTick && _tick != null) {
      _tick?.cancel();
      _tick = null;
    }

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
                final eta = OrderDeliveryTimeline.liveListEta(o.placedAt, o.status);
                return Card(
                  child: ListTile(
                    key: Key('order_tile_${o.id}'),
                    title: Text(o.id),
                    subtitle: Text(
                      '${o.status.uiLabel} · $eta · ${o.lines.length} items · ₹${o.total}',
                    ),
                    isThreeLine: true,
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

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }
}
