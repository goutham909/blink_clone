import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../data/models/product.dart';
import 'product_image_placeholder.dart';

class SearchHistoryChip extends StatelessWidget {
  const SearchHistoryChip({
    super.key,
    required this.label,
    this.product,
    required this.onTap,
  });

  final String label;
  final Product? product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBlinkDarkSurface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: ProductImagePlaceholder(
                      imageHint: product!.imageHint,
                      accent: Theme.of(context).colorScheme.primary,
                      height: 28,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                )
              else
                Icon(Icons.search, size: 20, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
