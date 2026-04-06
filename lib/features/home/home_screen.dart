import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../data/models/category_chip.dart';
import '../../data/models/product.dart';
import '../../providers/providers.dart';
import '../../widgets/product_card.dart';
import 'home_festival_theme.dart';
import 'widgets/address_bottom_sheet.dart';
import 'widgets/deal_cards_grid.dart';
import 'widgets/home_category_chips.dart';
import 'widgets/home_category_feed.dart';
import 'widgets/home_festival_sections.dart';
import 'widgets/home_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _homeCategoryId = 'cat_all';

  static const _festivalInterval = Duration(seconds: 12);
  Timer? _festivalTimer;
  int _festivalIndex = 0;

  HomeFestivalVisuals get _festivalVisuals =>
      HomeFestivalVisuals.rotation[_festivalIndex];

  @override
  void initState() {
    super.initState();
    _festivalTimer = Timer.periodic(_festivalInterval, (_) {
      if (!mounted) return;
      setState(() {
        _festivalIndex =
            (_festivalIndex + 1) % HomeFestivalVisuals.rotation.length;
      });
    });
  }

  @override
  void dispose() {
    _festivalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(catalogProvider);
    final totals = ref.watch(cartTotalsProvider);
    final selected = ref.watch(selectedAddressProvider);
    final hideSensitive = ref.watch(hideSensitiveProvider);

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Failed to load: $e')),
      ),
      data: (catalog) {
        final locationTitle = selected?.label ?? catalog.locationLabel;
        final festivalVisuals = _festivalVisuals;

        final homeBodyDark = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: kBlinkScreenBg,
          colorScheme: ColorScheme.dark(
            surface: kBlinkScreenBg,
            onSurface: Colors.white,
            primary: kBlinkGreen,
            secondary: kBlinkGold,
            outline: kBlinkMutedOnDark,
          ),
        );

        final bottomNavClearance =
            MediaQuery.viewPaddingOf(context).bottom + 80;
        final scrollBottomPad =
            bottomNavClearance + (totals.itemCount > 0 ? 76 : 12);

        final categorySection = _homeCategoryId == 'cat_all'
            ? null
            : catalog.homeCategorySectionFor(_homeCategoryId);
        CategoryChipData? shelfChip;
        if (_homeCategoryId != 'cat_all') {
          for (final c in catalog.categories) {
            if (c.id == _homeCategoryId) {
              shelfChip = c;
              break;
            }
          }
        }
        final shelfTitle = categorySection?.title ?? '${shelfChip?.label ?? 'Shop'} picks';
        final shelfSubtitle = categorySection?.subtitle;
        final shelfProducts = _homeCategoryId == 'cat_all'
            ? const <Product>[]
            : catalog
                .shelfProductsForCategory(_homeCategoryId)
                .where((p) => visibleWithSensitiveFilter(p, hideSensitive))
                .toList();

        return Scaffold(
          key: const Key('screen_home'),
          backgroundColor: kBlinkScreenBg,
          body: Stack(
            children: [
              Theme(
                data: homeBodyDark,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                  SliverToBoxAdapter(
                    child: HomeHeader(
                      visuals: festivalVisuals,
                      locationTitle: locationTitle,
                      deliveryMinutes: catalog.deliveryMinutes,
                      onLocationTap: () => showAddressBottomSheet(context, catalog),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: festivalVisuals.stripBelowHeaderColor,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: _HomeSearchEntryBar(
                          onTap: () => context.pushNamed('search'),
                          backgroundColor: festivalVisuals.searchBarBackground,
                          hintColor: festivalVisuals.searchBarHintStyleColor,
                          iconColor: festivalVisuals.searchBarIconColor,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: HomeCategoryChipsRow(
                      categories: catalog.categories,
                      selectedId: _homeCategoryId,
                      visuals: festivalVisuals,
                      onSelected: (chip) =>
                          setState(() => _homeCategoryId = chip.id),
                    ),
                  ),
                  if (_homeCategoryId == 'cat_all') ...[
                    SliverToBoxAdapter(
                      child: ColoredBox(
                        color: festivalVisuals.promoBackdropColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (catalog.poweredBy.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Text(
                                        'POWERED BY',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Colors.white38,
                                              letterSpacing: 0.6,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(width: 10),
                                      ...catalog.poweredBy.map(
                                        (b) => Padding(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: InkWell(
                                            onTap: () => context.pushNamed(
                                              'search',
                                              queryParameters: {'q': b},
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                            child: Text(
                                              b,
                                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                    color: Colors.white70,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration.underline,
                                                    decorationColor: Colors.white30,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: FestivalPromoSwitcher(
                                visuals: festivalVisuals,
                                summerChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SummerPromoTitle(),
                                    DealCardsGrid(
                                      deals: catalog.dealCards,
                                      onDealTap: (deal) {
                                        final id = deal.targetCategoryId;
                                        if (id != null) {
                                          context.pushNamed(
                                            'search',
                                            queryParameters: {'category': id},
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                hanumanChild: HanumanFestivalHero(
                                  onSeeAll: () => context.pushNamed(
                                    'search',
                                    queryParameters: {'q': 'hanuman jayanti'},
                                  ),
                                ),
                                diwaliChild: DiwaliFestivalGrid(
                                  onCategoryTap: (query) => context.pushNamed(
                                    'search',
                                    queryParameters: {'q': query},
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ColoredBox(
                        color: kBlinkScreenBg,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                          child: _LowestPricesBanner(
                            onTap: () => context.pushNamed(
                              'search',
                              queryParameters: {'rail': 'rail_lowest'},
                            ),
                          ),
                        ),
                      ),
                    ),
                    ...catalog.rails.expand((rail) {
                      final byId = catalog.productById;
                      final products = rail.productIds
                          .map((id) => byId[id])
                          .whereType()
                          .where((p) => visibleWithSensitiveFilter(p, hideSensitive))
                          .toList();
                      if (products.isEmpty) return <Widget>[];
                      return [
                        SliverToBoxAdapter(
                          child: ColoredBox(
                            color: kBlinkScreenBg,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Text(
                                rail.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      letterSpacing: -0.3,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: ColoredBox(
                            color: kBlinkScreenBg,
                            child: SizedBox(
                              height: 300,
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
                                      width: 158,
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
                        color: kBlinkScreenBg,
                        child: SizedBox(height: scrollBottomPad),
                      ),
                    ),
                  ] else
                    SliverToBoxAdapter(
                      child: HomeCategoryFeed(
                        title: shelfTitle,
                        subtitle: shelfSubtitle,
                        products: shelfProducts,
                        categoryId: _homeCategoryId,
                        bottomPadding: scrollBottomPad,
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

class _HomeSearchEntryBar extends StatefulWidget {
  const _HomeSearchEntryBar({
    required this.onTap,
    required this.backgroundColor,
    required this.hintColor,
    required this.iconColor,
  });

  final VoidCallback onTap;
  final Color backgroundColor;
  final Color hintColor;
  final Color iconColor;

  @override
  State<_HomeSearchEntryBar> createState() => _HomeSearchEntryBarState();
}

class _HomeSearchEntryBarState extends State<_HomeSearchEntryBar> {
  static const _hints = [
    'yoga',
    'milk',
    'bread',
    'diapers',
    'chocolate',
    'bananas',
    'coffee',
    'paneer',
    'ice cream',
    'atta',
  ];

  static const _hintInterval = Duration(seconds: 3);

  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_hintInterval, (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _hints.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hintStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: widget.hintColor,
        );

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        key: const Key('home_search_entry'),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: widget.iconColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  heightFactor: 1,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.22),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ));
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: slide,
                          child: child,
                        ),
                      );
                    },
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.centerLeft,
                        clipBehavior: Clip.hardEdge,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: Text(
                      'Search "${_hints[_index]}"',
                      key: ValueKey<String>(_hints[_index]),
                      style: hintStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 22,
              margin: const EdgeInsets.only(left: 10, right: 10),
              color: widget.iconColor.withValues(alpha: 0.35),
            ),
            Icon(Icons.mic_none, color: widget.iconColor, size: 22),
          ],
        ),
      ),
    );
  }
}

class _LowestPricesBanner extends StatelessWidget {
  const _LowestPricesBanner({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
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
