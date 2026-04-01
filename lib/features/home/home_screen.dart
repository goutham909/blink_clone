import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/category_icons.dart';
import '../../core/constants.dart';
import '../../providers/providers.dart';
import '../../widgets/product_card.dart';
import 'widgets/address_bottom_sheet.dart';
import 'widgets/deal_cards_grid.dart';
import 'widgets/home_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(catalogProvider);
    final totals = ref.watch(cartTotalsProvider);
    final selected = ref.watch(selectedAddressProvider);

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Failed to load: $e')),
      ),
      data: (catalog) {
        final locationTitle = selected?.label ?? catalog.locationLabel;

        final homeBodyLight = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: kBlinkGreen,
            brightness: Brightness.light,
          ),
        );

        final bottomNavClearance =
            MediaQuery.viewPaddingOf(context).bottom + 80;
        final scrollBottomPad =
            bottomNavClearance + (totals.itemCount > 0 ? 76 : 12);

        return Scaffold(
          key: const Key('screen_home'),
          backgroundColor: const Color(0xFFF7F7F7),
          body: Stack(
            children: [
              Theme(
                data: homeBodyLight,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                  SliverToBoxAdapter(
                    child: HomeHeader(
                      locationTitle: locationTitle,
                      deliveryMinutes: catalog.deliveryMinutes,
                      onLocationTap: () => showAddressBottomSheet(context, catalog),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: const Color(0xFFF7F7F7),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: InkWell(
                          onTap: () => context.pushNamed('search'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            key: const Key('home_search_entry'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A3A3C),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.white54),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Search \'yoga\'',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.white54,
                                        ),
                                  ),
                                ),
                                const Icon(Icons.mic_none, color: Colors.white54),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: const Color(0xFFF7F7F7),
                      child: SizedBox(
                        height: 118,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          primary: false,
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                          itemCount: catalog.categories.length,
                          itemBuilder: (context, i) {
                            final c = catalog.categories[i];
                            final isFirstCategory = i == 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: InkWell(
                                onTap: () {},
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isFirstCategory ? Colors.black : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.06),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            iconForCategoryName(c.iconName),
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (c.badgeText != null)
                                          Positioned(
                                            right: -4,
                                            top: -4,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                c.badgeText!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      c.label,
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            color: Colors.black87,
                                            fontWeight: isFirstCategory ? FontWeight.w800 : FontWeight.w500,
                                          ),
                                    ),
                                    if (isFirstCategory)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        height: 3,
                                        width: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (catalog.poweredBy.isNotEmpty)
                    SliverToBoxAdapter(
                      child: ColoredBox(
                        color: const Color(0xFFF7F7F7),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                'POWERED BY',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.black45,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              ...catalog.poweredBy.map(
                                (b) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    b,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: const Color(0xFFF7F7F7),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DealCardsGrid(deals: catalog.dealCards),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: const Color(0xFFF7F7F7),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                        child: _LowestPricesBanner(),
                      ),
                    ),
                  ),
                  ...catalog.rails.expand((rail) {
                    final byId = catalog.productById;
                    final products = rail.productIds
                        .map((id) => byId[id])
                        .whereType()
                        .toList();
                    if (products.isEmpty) return <Widget>[];
                    return [
                      SliverToBoxAdapter(
                        child: ColoredBox(
                          color: const Color(0xFFF7F7F7),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              rail.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: ColoredBox(
                          color: const Color(0xFFF7F7F7),
                          child: SizedBox(
                            height: 280,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              primary: false,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: products.length,
                              itemBuilder: (context, i) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: ProductCard(
                                    product: products[i],
                                    width: 150,
                                    layout: ProductCardLayout.rail,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ];
                  }),
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: const Color(0xFFF7F7F7),
                      child: SizedBox(height: scrollBottomPad),
                    ),
                  ),
                  ],
                ),
              ),
              if (totals.itemCount > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        color: kBlinkGreen,
                        child: InkWell(
                          onTap: () => context.pushNamed('cart'),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Text(
                                  '${totals.itemCount} items',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'View cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ),
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

class _LowestPricesBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipPath(
        clipper: _JaggedClipper(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3D2914),
                Color(0xFF5C3D1E),
              ],
            ),
          ),
          child: Transform.rotate(
            angle: -0.05,
            child: Text(
              'LOWEST PRICES EVER',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: kBlinkAmber,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JaggedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 8);
    for (var x = 0.0; x < size.width; x += 14) {
      path.lineTo(x + 7, 0);
      path.lineTo(x + 14, 8);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
