import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/models/mock_catalog.dart';
import '../../data/models/product.dart';
import '../../data/models/product_rail.dart';
import '../../providers/providers.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_image_placeholder.dart';
import '../../widgets/search_chip.dart';
import 'widgets/autocomplete_list.dart';
import 'widgets/filter_chips_bar.dart';

enum _SearchSort { relevance, priceLow, priceHigh }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  bool _showAutocomplete = true;
  _SearchSort _sort = _SearchSort.relevance;
  bool _inStockOnly = false;
  bool _seededQueryFromRoute = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seededQueryFromRoute) return;
    final q = GoRouterState.of(context).uri.queryParameters['q'];
    if (q != null && q.trim().isNotEmpty) {
      _controller.text = q.trim();
    }
    _seededQueryFromRoute = true;
  }

  List<Product> _autocompleteSuggestions(String q, List<Product> all, bool hideSensitive) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return [];
    final scored = <Product>[];
    for (final p in all) {
      if (!visibleWithSensitiveFilter(p, hideSensitive)) continue;
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

  List<Product> _applyScope(
    List<Product> list,
    MockCatalog catalog,
    String? categoryId,
    String? railId,
    bool hideSensitive,
  ) {
    var out = list.where((p) => visibleWithSensitiveFilter(p, hideSensitive)).toList();
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'cat_all') {
      out = out.where((p) => p.categoryId == categoryId).toList();
    }
    if (railId != null && railId.isNotEmpty) {
      ProductRail? rail;
      for (final r in catalog.rails) {
        if (r.id == railId) {
          rail = r;
          break;
        }
      }
      if (rail != null) {
        final set = rail.productIds.toSet();
        out = out.where((p) => set.contains(p.id)).toList();
      }
    }
    if (_inStockOnly) {
      out = out.where((p) => p.inStock).toList();
    }
    return out;
  }

  List<Product> _applySort(List<Product> list) {
    final next = List<Product>.from(list);
    switch (_sort) {
      case _SearchSort.priceLow:
        next.sort((a, b) => a.salePrice.compareTo(b.salePrice));
        break;
      case _SearchSort.priceHigh:
        next.sort((a, b) => b.salePrice.compareTo(a.salePrice));
        break;
      case _SearchSort.relevance:
        break;
    }
    return next;
  }

  String _sortLabel() {
    switch (_sort) {
      case _SearchSort.priceLow:
        return 'Price ↑';
      case _SearchSort.priceHigh:
        return 'Price ↓';
      case _SearchSort.relevance:
        return 'Sort';
    }
  }

  Future<void> _showSortSheet() async {
    final picked = await showModalBottomSheet<_SearchSort>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<_SearchSort>(
              title: const Text('Relevance'),
              value: _SearchSort.relevance,
              groupValue: _sort,
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
            RadioListTile<_SearchSort>(
              title: const Text('Price: low to high'),
              value: _SearchSort.priceLow,
              groupValue: _sort,
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
            RadioListTile<_SearchSort>(
              title: const Text('Price: high to low'),
              value: _SearchSort.priceHigh,
              groupValue: _sort,
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _sort = picked);
  }

  Future<void> _showFiltersSheet() async {
    var local = _inStockOnly;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Filters', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              SwitchListTile(
                title: const Text('In stock only'),
                value: local,
                onChanged: (v) {
                  if (v != null) setModal(() => local = v);
                },
              ),
              FilledButton(
                onPressed: () {
                  setState(() => _inStockOnly = local);
                  Navigator.pop(ctx);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Product> _browseCategoryProducts(MockCatalog catalog, String categoryId, bool hideSensitive) {
    return catalog.products
        .where((p) => p.categoryId == categoryId)
        .where((p) => visibleWithSensitiveFilter(p, hideSensitive))
        .toList();
  }

  List<Product> _browseRailProducts(MockCatalog catalog, String railId, bool hideSensitive) {
    ProductRail? rail;
    for (final r in catalog.rails) {
      if (r.id == railId) {
        rail = r;
        break;
      }
    }
    if (rail == null) return [];
    final byId = catalog.productById;
    return rail.productIds
        .map((id) => byId[id])
        .whereType<Product>()
        .where((p) => visibleWithSensitiveFilter(p, hideSensitive))
        .toList();
  }

  String? _categoryLabel(MockCatalog catalog, String? categoryId) {
    if (categoryId == null) return null;
    for (final c in catalog.categories) {
      if (c.id == categoryId) return c.label;
    }
    return categoryId;
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogProvider);
    final userRecent = ref.watch(recentSearchesNotifierProvider);
    final hideSensitive = ref.watch(hideSensitiveProvider);
    final uri = GoRouterState.of(context).uri;
    final categoryParam = uri.queryParameters['category'];
    final railParam = uri.queryParameters['rail'];

    return catalogAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (catalog) {
        final all = catalog.products;
        final byId = catalog.productById;
        final q = _controller.text;
        final suggestions = _autocompleteSuggestions(q, all, hideSensitive);
        var results = _searchResults(q, all);
        results = _applyScope(results, catalog, categoryParam, railParam, hideSensitive);
        results = _applySort(results);

        final catalogRecent = catalog.recentSearches
            .map((e) => MapEntry(e.query, e.thumbProductId != null ? byId[e.thumbProductId!] : null))
            .toList();

        var topPicks = catalog.rails.isNotEmpty
            ? catalog.rails.first.productIds.map((id) => byId[id]).whereType<Product>().toList()
            : all.take(8).toList();
        topPicks = topPicks.where((p) => visibleWithSensitiveFilter(p, hideSensitive)).toList();

        var trending = catalog.trendingProductIds
            .map((id) => byId[id])
            .whereType<Product>()
            .where((p) => visibleWithSensitiveFilter(p, hideSensitive))
            .toList();

        final browseCategory = categoryParam != null && categoryParam.isNotEmpty && categoryParam != 'cat_all'
            ? _browseCategoryProducts(catalog, categoryParam, hideSensitive)
            : <Product>[];
        final browseRail = railParam != null && railParam.isNotEmpty
            ? _browseRailProducts(catalog, railParam, hideSensitive)
            : <Product>[];

        String? browseHeading;
        if (browseRail.isNotEmpty) {
          for (final r in catalog.rails) {
            if (r.id == railParam) {
              browseHeading = r.title;
              break;
            }
          }
        } else if (browseCategory.isNotEmpty) {
          browseHeading = _categoryLabel(catalog, categoryParam);
        }

        void openProduct(Product p) {
          context.pushNamed('product', pathParameters: {'id': p.id});
        }

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
                    autofocus: q.trim().isEmpty && categoryParam == null && railParam == null,
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice search is not available in this demo')),
                    );
                  },
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
                  browseTitle: browseHeading,
                  browseProducts: browseRail.isNotEmpty ? browseRail : browseCategory,
                  onChipTap: (text) {
                    setState(() {
                      _controller.text = text;
                      _showAutocomplete = false;
                    });
                    ref.read(recentSearchesNotifierProvider.notifier).add(text);
                  },
                  onClearRecent: () => ref.read(recentSearchesNotifierProvider.notifier).clear(),
                  onOpenProduct: openProduct,
                  onSeeAllProducts: () => context.go('/categories'),
                )
              : CustomScrollView(
                  slivers: [
                    if (_showAutocomplete && suggestions.isNotEmpty)
                      SliverToBoxAdapter(
                        child: AutocompleteList(
                          suggestions: suggestions,
                          onSelect: (p) {
                            ref.read(recentSearchesNotifierProvider.notifier).add(p.name);
                            setState(() => _showAutocomplete = false);
                            openProduct(p);
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
                    SliverToBoxAdapter(
                      child: FilterChipsBar(
                        sortLabel: _sortLabel(),
                        onFiltersTap: _showFiltersSheet,
                        onSortTap: _showSortSheet,
                        onBrandTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pick a brand from product pages (demo)')),
                          );
                        },
                        onFlavourTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Flavour filters coming soon (demo)')),
                          );
                        },
                      ),
                    ),
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
    required this.onOpenProduct,
    required this.onSeeAllProducts,
    this.browseTitle,
    this.browseProducts,
  });

  final List<MapEntry<String, Product?>> catalogRecent;
  final List<String> userRecent;
  final Map<String, Product> byId;
  final List<Product> topPicks;
  final List<Product> trending;
  final ValueChanged<String> onChipTap;
  final VoidCallback onClearRecent;
  final void Function(Product p) onOpenProduct;
  final VoidCallback onSeeAllProducts;
  final String? browseTitle;
  final List<Product>? browseProducts;

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
    final browse = browseProducts ?? const <Product>[];

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (browseTitle != null && browse.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              browseTitle!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: browse.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ProductCard(
                    product: browse[i],
                    width: 160,
                    layout: ProductCardLayout.rail,
                  ),
                );
              },
            ),
          ),
        ],
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
            onPressed: onSeeAllProducts,
            child: const Row(
              children: [
                Icon(Icons.shopping_bag_outlined, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('See all products')),
                Icon(Icons.chevron_right),
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onOpenProduct(p),
                    borderRadius: BorderRadius.circular(12),
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
