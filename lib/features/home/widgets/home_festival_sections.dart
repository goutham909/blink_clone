import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../home_festival_theme.dart';

/// Hanuman Jayanti–style hero + sub-banner (placeholder art via icons).
class HanumanFestivalHero extends StatelessWidget {
  const HanumanFestivalHero({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 12, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF5D4037),
                  Color(0xFF4E342E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CELEBRATE',
                        style: t.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hanuman Jayanti',
                        style: t.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: onSeeAll,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'See all products',
                                style: t.labelLarge?.copyWith(
                                  color: kBlinkAmber,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: kBlinkAmber, size: 22),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FestiveIconDisc(icon: Icons.temple_hindu, color: const Color(0xFFFFD700)),
                    const SizedBox(width: 8),
                    _FestiveIconDisc(icon: Icons.flag, color: const Color(0xFFFF6F00)),
                    const SizedBox(width: 8),
                    _FestiveIconDisc(icon: Icons.local_fire_department, color: const Color(0xFFFFAB40)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: const Color(0xFF6D4C41),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE082),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.cookie, color: Color(0xFF5D4037)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Get besan laddu from Ayodhya & more',
                        style: t.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FestiveIconDisc extends StatelessWidget {
  const _FestiveIconDisc({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black26,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

/// Diwali-style 2×4 category grid (tapping opens search).
class DiwaliFestivalGrid extends StatelessWidget {
  const DiwaliFestivalGrid({super.key, required this.onCategoryTap});

  final void Function(String query) onCategoryTap;

  static const _items = [
    _DiwaliTile('Home Decor', Icons.home_outlined, Color(0xFFFFF8E1)),
    _DiwaliTile('Diwali Gifting', Icons.card_giftcard, Color(0xFFFFEBEE)),
    _DiwaliTile('Diwali Party', Icons.celebration, Color(0xFFF3E5F5)),
    _DiwaliTile('Premium Dry Fruits', Icons.eco, Color(0xFFE8F5E9)),
    _DiwaliTile('Pooja & Flowers', Icons.local_florist, Color(0xFFFFFDE7)),
    _DiwaliTile('Indian Sweets', Icons.icecream, Color(0xFFFFE0B2)),
    _DiwaliTile('Silver & Gold Coins', Icons.monetization_on_outlined, Color(0xFFECEFF1)),
    _DiwaliTile('Festive Ready', Icons.shopping_bag_outlined, Color(0xFFE1F5FE)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Celebrate Diwali',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Festive needs delivered in minutes',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemCount: _items.length,
            itemBuilder: (context, i) {
              final tile = _items[i];
              return Material(
                color: tile.tint,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => onCategoryTap(tile.label),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Icon(
                            tile.icon,
                            size: 32,
                            color: const Color(0xFF5D4037),
                          ),
                        ),
                        Text(
                          tile.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DiwaliTile {
  const _DiwaliTile(this.label, this.icon, this.tint);

  final String label;
  final IconData icon;
  final Color tint;
}

/// Summer promo title shown above the deal grid while on summer theme.
class SummerPromoTitle extends StatelessWidget {
  const SummerPromoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kBlinkOrangeBanner.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'SUMMER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: kBlinkOrangeBanner,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Deals & picks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
          ),
        ],
      ),
    );
  }
}

/// Wraps the rotating promo region with a smooth cross-fade.
class FestivalPromoSwitcher extends StatelessWidget {
  const FestivalPromoSwitcher({
    super.key,
    required this.visuals,
    required this.summerChild,
    required this.hanumanChild,
    required this.diwaliChild,
  });

  final HomeFestivalVisuals visuals;
  final Widget summerChild;
  final Widget hanumanChild;
  final Widget diwaliChild;

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (visuals.kind) {
      case HomeFestivalKind.summer:
        child = summerChild;
        break;
      case HomeFestivalKind.hanuman:
        child = hanumanChild;
        break;
      case HomeFestivalKind.diwali:
        child = diwaliChild;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 520),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) {
        return Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          children: [
            ...previous,
            if (current != null) current,
          ],
        );
      },
      transitionBuilder: (widget, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: widget,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<HomeFestivalKind>(visuals.kind),
        child: child,
      ),
    );
  }
}
