import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/models/product.dart';
import '../../providers/providers.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_image_placeholder.dart';
import '../../widgets/search_chip.dart';
import 'widgets/autocomplete_list.dart';
import 'widgets/filter_chips_bar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  bool _showAutocomplete = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Product> _autocompleteSuggestions(String q, List<Product> all) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return [];
    final scored = <Product>[];
    for (final p in all) {
      final n = p.name.toLowerCase();
      if (n.startsWith(s)) {
        scored.add(p);
      } else if (n.contains(s)) {
        scored.add(p);
      }
    }
    scored.sort((a, b) {
      final na = a.name.toLowerCase();
      final nb = b.name.toLowerCase();
      final sa = na.startsWith(s) ? 0 : 1;
      final sb = nb.startsWith(s) ? 0 : 1;
      if (sa != sb) return sa.compareTo(sb);
      return na.compareTo(nb);
    });
    return scored.take(5).toList();
  }

  List<Product> _searchResults(String q, List<Product> all) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return [];
    return all
        .where(
          (p) =>
              p.name.toLowerCase().contains(s) ||
              p.unit.toLowerCase().contains(s) ||
              p.id.toLowerCase().contains(s),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogProvider);
    final userRecent = ref.watch(recentSearchesNotifierProvider);

    return catalogAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (catalog) {
        final all = catalog.products;
        final byId = catalog.productById;
        final q = _controller.text;
        final suggestions = _autocompleteSuggestions(q, all);
        final results = _searchResults(q, all);

        final catalogRecent = catalog.recentSearches
            .map((e) => MapEntry(e.query, e.thumbProductId != null ? byId[e.thumbProductId!] : null))
            .toList();

        final topPicks = catalog.rails.isNotEmpty
            ? catalog.rails.first.productIds.map((id) => byId[id]).whereType<Product>().toList()
            : all.take(8).toList();

        final trending = catalog.trendingProductIds
            .map((id) => byId[id])
            .whereType<Product>()
            .toList();

        return Scaffold(
          key: const Key('screen_search'),
          backgroundColor: kBlinkDarkBg,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('search_field'),
                    controller: _controller,
                    autofocus: true,
                    onChanged: (_) => setState(() => _showAutocomplete = true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search for atta, dal, coke and mo...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (v) {
                      ref.read(recentSearchesNotifierProvider.notifier).add(v);
                      setState(() => _showAutocomplete = false);
                    },
                  ),
                ),
                if (q.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _showAutocomplete = true);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.mic_none),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          body: q.trim().isEmpty
              ? _SearchLandingBody(
                  catalogRecent: catalogRecent,
                  userRecent: userRecent,
                  byId: byId,
                  topPicks: topPicks,
                  trending: trending,
                  onChipTap: (text) {
                    setState(() {
                      _controller.text = text;
                      _showAutocomplete = false;
                    });
                    ref.read(recentSearchesNotifierProvider.notifier).add(text);
                  },
                  onClearRecent: () => ref.read(recentSearchesNotifierProvider.notifier).clear(),
                )
              : CustomScrollView(
                  slivers: [
                    if (_showAutocomplete && suggestions.isNotEmpty)
                      SliverToBoxAdapter(
                        child: AutocompleteList(
                          suggestions: suggestions,
                          onSelect: (p) {
                            _controller.text = p.name;
                            ref.read(recentSearchesNotifierProvider.notifier).add(p.name);
                            setState(() => _showAutocomplete = false);
                          },
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          "Showing results for '$q'",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: FilterChipsBar()),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    if (results.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text('No items match your search')),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.48,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final p = results[i];
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return ProductCard(
                                    product: p,
                                    width: constraints.maxWidth,
                                    layout: ProductCardLayout.grid,
                                  );
                                },
                              );
                            },
                            childCount: results.length,
                          ),
                        ),
                      ),
                    if (results.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Because you love ${catalog.recommendationBrand}',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: trending.length,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: ProductCard(
                                        product: trending[i],
                                        width: 130,
                                        layout: ProductCardLayout.rail,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _SearchLandingBody extends StatelessWidget {
  const _SearchLandingBody({
    required this.catalogRecent,
    required this.userRecent,
    required this.byId,
    required this.topPicks,
    required this.trending,
    required this.onChipTap,
    required this.onClearRecent,
  });

  final List<MapEntry<String, Product?>> catalogRecent;
  final List<String> userRecent;
  final Map<String, Product> byId;
  final List<Product> topPicks;
  final List<Product> trending;
  final ValueChanged<String> onChipTap;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    final merged = <String, Product?>{};
    for (final e in catalogRecent) {
      merged[e.key] = e.value;
    }
    for (final q in userRecent) {
      merged.putIfAbsent(q, () => null);
    }
    final entries = merged.entries.toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text(
                'Recent searches',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: entries.isEmpty ? null : onClearRecent,
                child: const Text('clear'),
              ),
            ],
          ),
        ),
        if (entries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entries.map((e) {
                Product? t = e.value;
                if (t == null) {
                  for (final p in byId.values) {
                    if (p.name.toLowerCase().contains(e.key.toLowerCase())) {
                      t = p;
                      break;
                    }
                  }
                }
                return SearchHistoryChip(
                  label: e.key,
                  product: t,
                  onTap: () => onChipTap(e.key),
                );
              }).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'Top picks for you',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: topPicks.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ProductCard(
                  product: topPicks[i],
                  width: 160,
                  layout: ProductCardLayout.rail,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton(
            onPressed: () {},
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 20),
                const SizedBox(width: 8),
                const Expanded(child: Text('See all products')),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'Trending in your city',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: trending.length,
            itemBuilder: (context, i) {
              final p = trending[i];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ProductImagePlaceholder(
                          imageHint: p.imageHint,
                          accent: Theme.of(context).colorScheme.primary,
                          height: 72,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 80,
                      child: Text(
                        p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
