import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

class QuantityStepper extends ConsumerWidget {
  const QuantityStepper({
    super.key,
    required this.productId,
    required this.enabled,
  });

  final String productId;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qty = ref.watch(cartProvider)[productId] ?? 0;
    final cart = ref.read(cartProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    if (!enabled) {
      return const SizedBox.shrink();
    }

    if (qty <= 0) {
      return FilledButton.tonal(
        key: Key('stepper_add_$productId'),
        onPressed: () => cart.addOne(productId),
        child: const Text('ADD'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: Key('stepper_dec_$productId'),
            visualDensity: VisualDensity.compact,
            onPressed: () => cart.removeOne(productId),
            icon: const Icon(Icons.remove),
          ),
          Text(
            '$qty',
            key: Key('stepper_qty_$productId'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            key: Key('stepper_inc_$productId'),
            visualDensity: VisualDensity.compact,
            onPressed: () => cart.addOne(productId),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
