import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

Future<void> showDebugPanel(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Debug',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).clear();
                  Navigator.pop(ctx);
                },
                child: const Text('Clear cart'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  ref.read(ordersProvider.notifier).clear();
                  Navigator.pop(ctx);
                },
                child: const Text('Clear orders'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  await ref.read(mockCatalogSourceProvider).clearCache();
                  ref.invalidate(catalogProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Reload catalog cache'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
