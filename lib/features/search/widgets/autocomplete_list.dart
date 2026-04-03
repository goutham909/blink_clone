import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../data/models/product.dart';
import '../../../widgets/catalog_image.dart';

class AutocompleteList extends StatelessWidget {
  const AutocompleteList({
    super.key,
    required this.suggestions,
    required this.onSelect,
  });

  final List<Product> suggestions;
  final ValueChanged<Product> onSelect;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Material(
      color: kBlinkDarkBg,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
        itemBuilder: (context, i) {
          final p = suggestions[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: CatalogImage(
                  imageRef: p.imageRef,
                  imageHint: p.imageHint,
                  accent: Theme.of(context).colorScheme.primary,
                  height: 44,
                  borderRadius: BorderRadius.circular(8),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              p.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () => onSelect(p),
          );
        },
      ),
    );
  }
}
