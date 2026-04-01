import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/order_delivery_timeline.dart';
import '../../data/models/order_models.dart';
import '../../providers/providers.dart';

/// Live order tracking: progress and countdown update automatically (no refresh).
class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (!mounted) return;
      final o = _findOrder(ref.read(ordersProvider));
      if (o == null) {
        _tick?.cancel();
        _tick = null;
        setState(() {});
        return;
      }
      setState(() {});
      if (o.status == OrderStatus.delivered) {
        _tick?.cancel();
        _tick = null;
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  OrderRecord? _findOrder(List<OrderRecord> orders) {
    for (final o in orders) {
      if (o.id == widget.orderId) return o;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);
    final o = _findOrder(orders);

    if (o == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Order not found')),
      );
    }

    final barValue = o.status == OrderStatus.delivered
        ? 1.0
        : OrderDeliveryTimeline.smoothProgress(o.placedAt).clamp(0.0, 1.0);
    final caption = OrderDeliveryTimeline.liveDetailLine(o.placedAt, o.status);

    return Scaffold(
      key: Key('screen_order_${widget.orderId}'),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barValue,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Text(
              caption,
              key: ValueKey<String>(caption),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Packed 30s · Ordered 1 min · Delivered 11 min from placed',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 12),
          ...OrderStatus.values.map(
            (s) => ListTile(
              dense: true,
              leading: Icon(
                s.uiIcon,
                color: s.index <= o.status.index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              title: Text(s.uiLabel),
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.pushNamed(
                    'product',
                    pathParameters: {'id': l.product.id},
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l.product.name} × ${l.quantity}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text('₹${l.lineTotal}'),
                      ],
                    ),
                  ),
                ),
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
}
