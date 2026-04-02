import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/models/mock_catalog.dart';
import '../../data/models/order_models.dart';
import '../../data/models/product.dart';
import '../../providers/providers.dart';
import '../../widgets/product_image_placeholder.dart';
import '../home/widgets/address_bottom_sheet.dart';
import '../home/home_festival_theme.dart';
import '../home/widgets/home_header.dart';

/// Blinkit-style “Order again” — category grids (frequently bought), not order status list.
class OrderAgainScreen extends ConsumerWidget {
  const OrderAgainScreen({super.key});

  static const _defaultFrequent = <(String title, String categoryId)>[
    ('Chips & Namkeen', 'cat_snacks'),
    ('Milk, Curd & Paneer', 'cat_dairy'),
    ('Drinks & Juices', 'cat_bev'),
    ('Kitchen & groceries', 'cat_house'),
    ('Beauty & care', 'cat_beauty'),
  ];

  static const _defaultMore = <(String title, String categoryId)>[
    ('Summer picks', 'cat_summer'),
    ('Pharma & health', 'cat_pharma'),
    ('Electronics', 'cat_elec'),
    ('Frozen & instant', 'cat_snacks'),
    ('Bread & bakery', 'cat_snacks'),
    ('Tea & coffee', 'cat_bev'),
  ];

  static Map<String, List<String>> _productsByCategoryFromOrders(List<OrderRecord> orders) {
    final m = <String, List<String>>{};
    for (final o in orders) {
      for (final l in o.lines) {
        final id = l.product.categoryId;
        m.putIfAbsent(id, () => []);
        if (!m[id]!.contains(l.product.id)) {
          m[id]!.add(l.product.id);
        }
      }
    }
    return m;
  }

  static List<_OrderAgainTile> _buildSectionTiles({
    required bool isFirstSection,
    required List<OrderRecord> orders,
    required Set<String> wishlistIds,
    required MockCatalog catalog,
    required bool hideSensitive,
    required Set<String> excludeCategoryIds,
  }) {
    final fromOrders = _productsByCategoryFromOrders(orders);
    final sorted = fromOrders.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    final tiles = <_OrderAgainTile>[];
    final usedCats = <String>{...excludeCategoryIds};

    if (isFirstSection) {
      final favProducts = _resolveFavourites(wishlistIds, catalog, hideSensitive);
      tiles.add(
        _OrderAgainTile(
          title: 'Favourites',
          categoryId: null,
          isFavourites: true,
          products: favProducts,
        ),
      );
    }

    void addCategoryTile(String categoryId, String title) {
      if (categoryId == 'cat_all' || usedCats.contains(categoryId)) return;
      final products = _resolveCategoryProducts(
        categoryId,
        orderProductIds: fromOrders[categoryId],
        catalog: catalog,
        hideSensitive: hideSensitive,
      );
      if (products.isEmpty) return;
      usedCats.add(categoryId);
      tiles.add(_OrderAgainTile(title: title, categoryId: categoryId, products: products));
    }

    const targetCount = 6;
    for (final e in sorted) {
      if (tiles.length >= targetCount) break;
      final label = _categoryLabel(catalog, e.key) ?? e.key;
      addCategoryTile(e.key, label);
    }

    final defaults = isFirstSection ? _defaultFrequent : _defaultMore;
    for (final pair in defaults) {
      if (tiles.length >= targetCount) break;
      addCategoryTile(pair.$2, pair.$1);
    }

    return tiles.take(targetCount).toList();
  }

  static String? _categoryLabel(MockCatalog catalog, String id) {
    for (final c in catalog.categories) {
      if (c.id == id) return c.label;
    }
    return null;
  }

  static List<Product> _resolveFavourites(
    Set<String> wishlistIds,
    MockCatalog catalog,
    bool hideSensitive,
  ) {
    final list = wishlistIds
        .map((id) => catalog.productById[id])
        .whereType<Product>()
        .where((p) => visibleWithSensitiveFilter(p, hideSensitive))
        .toList();
    if (list.isNotEmpty) return list;
    const seed = ['p_chips', 'p_biscuit', 'p_bread'];
    return seed.map((id) => catalog.productById[id]).whereType<Product>().toList();
  }

  static List<Product> _resolveCategoryProducts(
    String categoryId, {
    List<String>? orderProductIds,
    required MockCatalog catalog,
    required bool hideSensitive,
  }) {
    final ids = <String>[];
    final seen = <String>{};
    for (final id in orderProductIds ?? const []) {
      if (seen.add(id)) ids.add(id);
    }
    for (final p in catalog.products) {
      if (p.categoryId != categoryId) continue;
      if (!visibleWithSensitiveFilter(p, hideSensitive)) continue;
      if (seen.add(p.id)) ids.add(p.id);
      if (ids.length >= 32) break;
    }
    return ids.map((id) => catalog.productById[id]).whereType<Product>().toList();
  }

  static void _onTileTap(BuildContext context, _OrderAgainTile tile) {
    if (tile.isFavourites) {
      context.pushNamed('wishlist');
      return;
    }
    if (tile.categoryId != null) {
      context.pushNamed('search', queryParameters: {'category': tile.categoryId!});
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final wishlist = ref.watch(wishlistProvider);
    final catalogAsync = ref.watch(catalogProvider);
    final selected = ref.watch(selectedAddressProvider);
    final hideSensitive = ref.watch(hideSensitiveProvider);

    return catalogAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (catalog) {
        final locationTitle = selected?.label ?? catalog.locationLabel;
        final frequent = _buildSectionTiles(
          isFirstSection: true,
          orders: orders,
          wishlistIds: wishlist,
          catalog: catalog,
          hideSensitive: hideSensitive,
          excludeCategoryIds: {},
        );
        final used = frequent.map((t) => t.categoryId).whereType<String>().toSet();
        final more = _buildSectionTiles(
          isFirstSection: false,
          orders: orders,
          wishlistIds: wishlist,
          catalog: catalog,
          hideSensitive: hideSensitive,
          excludeCategoryIds: used,
        );

        final bottomPad = MediaQuery.viewPaddingOf(context).bottom + 88;

        return Scaffold(
          key: const Key('screen_order_again'),
          backgroundColor: const Color(0xFF121212),
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  visuals: HomeFestivalVisuals.summer,
                  locationTitle: locationTitle,
                  deliveryMinutes: catalog.deliveryMinutes,
                  showSurgeBadge: true,
                  onLocationTap: () => showAddressBottomSheet(context, catalog),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Material(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => context.pushNamed('search'),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.white.withValues(alpha: 0.45)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Search \'coconut water\'',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white54,
                                    ),
                              ),
                            ),
                            Icon(Icons.mic_none, color: Colors.white.withValues(alpha: 0.45)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Text(
                    'Frequently bought',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final tile = frequent[i];
                      return _FrequentCategoryCard(
                        tile: tile,
                        accent: kBlinkGreen,
                        onTap: () => _onTileTap(context, tile),
                      );
                    },
                    childCount: frequent.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                  child: Text(
                    'More that you ordered',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final tile = more[i];
                      return _FrequentCategoryCard(
                        tile: tile,
                        accent: kBlinkGreen,
                        onTap: () => _onTileTap(context, tile),
                      );
                    },
                    childCount: more.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
            ],
          ),
        );
      },
    );
  }
}

class _OrderAgainTile {
  const _OrderAgainTile({
    required this.title,
    required this.products,
    this.categoryId,
    this.isFavourites = false,
  });

  final String title;
  final String? categoryId;
  final bool isFavourites;
  final List<Product> products;
}

class _FrequentCategoryCard extends StatelessWidget {
  const _FrequentCategoryCard({
    required this.tile,
    required this.accent,
    required this.onTap,
  });

  final _OrderAgainTile tile;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumbs = tile.products.take(2).toList();
    final more = tile.products.length > 2 ? tile.products.length - 2 : 0;

    return Material(
      color: const Color(0xFF1A2D2D),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: thumbs.isNotEmpty
                          ? ProductImagePlaceholder(
                              imageHint: thumbs[0].imageHint,
                              accent: accent,
                              height: 44,
                              borderRadius: BorderRadius.circular(8),
                            )
                          : const ColoredBox(color: Color(0xFF2A3F3F)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: thumbs.length > 1
                          ? ProductImagePlaceholder(
                              imageHint: thumbs[1].imageHint,
                              accent: accent,
                              height: 44,
                              borderRadius: BorderRadius.circular(8),
                            )
                          : const ColoredBox(color: Color(0xFF2A3F3F)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (more > 0)
                Text(
                  '+$more more',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  ' ',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
                ),
              const Spacer(),
              Text(
                tile.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
