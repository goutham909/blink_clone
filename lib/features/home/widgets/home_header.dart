import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/providers.dart';
import '../home_festival_theme.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    required this.visuals,
    required this.locationTitle,
    required this.deliveryMinutes,
    required this.onLocationTap,
    this.showSurgeBadge,
  });

  /// When set, overrides [HomeFestivalVisuals.showSurgeBadge] (e.g. Order Again screen).
  final bool? showSurgeBadge;

  final HomeFestivalVisuals visuals;
  final String locationTitle;
  final int deliveryMinutes;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletBalanceProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: visuals.headerGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blinkit in',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: visuals.headerEyebrowColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                '$deliveryMinutes minutes',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: visuals.headerMinutesColor,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                      fontSize: 32,
                                      letterSpacing: -0.8,
                                    ),
                              ),
                            ),
                            if (showSurgeBadge ?? visuals.showSurgeBadge) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D9488),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.trending_up, size: 14, color: Colors.white.withValues(alpha: 0.95)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Surge applicable',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: onLocationTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  locationTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: visuals.headerBodyColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down, color: visuals.headerBodyColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Material(
                        color: const Color(0xFF3A3A3C),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => context.pushNamed('blinkitMoney'),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined,
                                    color: Colors.white.withValues(alpha: 0.9), size: 17),
                                const SizedBox(width: 5),
                                Text(
                                  '₹$wallet',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.98),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: visuals.profileCircleFill,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => context.pushNamed('account'),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.person_outline, color: visuals.profileIconColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
