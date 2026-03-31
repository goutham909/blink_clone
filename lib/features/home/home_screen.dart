import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(catalogProvider);

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Failed to load: $e')),
      ),
      data: (catalog) {
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          key: const Key('screen_home'),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: scheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Semantics(
                            label: 'location_pill',
                            child: Text(
                              catalog.locationLabel,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: InkWell(
                      onTap: () => context.go('/search'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        key: const Key('home_search_entry'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: scheme.outline),
                            const SizedBox(width: 10),
                            Text(
                              'Search items',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: scheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      itemCount: catalog.banners.length,
                      itemBuilder: (context, i) {
                        final b = catalog.banners[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Semantics(
                            label: 'banner_${b.id}',
                            child: Container(
                              key: Key('banner_${b.id}'),
                              width: 260,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    b.accentColor,
                                    b.accentColor.withValues(alpha: 0.75),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    b.subtitle,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.95),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: catalog.categories.length,
                      itemBuilder: (context, i) {
                        final c = catalog.categories[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Semantics(
                            label: 'category_${c.id}',
                            child: ActionChip(
                              key: Key('category_${c.id}'),
                              label: Text(c.label),
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ...catalog.rails.expand((rail) {
                  final byId = catalog.productById;
                  final products = rail.productIds
                      .map((id) => byId[id])
                      .whereType()
                      .toList();
                  return [
                    SliverToBoxAdapter(
                      child: SectionHeader(title: rail.title),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 230,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: products.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ProductCard(product: products[i]),
                            );
                          },
                        ),
                      ),
                    ),
                  ];
                }),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }
}
