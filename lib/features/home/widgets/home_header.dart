import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
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
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: visuals.headerMinutesColor,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
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
                        color: kBlinkGreen,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              showDragHandle: true,
                              builder: (ctx) => Padding(
                                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Blinkit Money',
                                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Balance: ₹$wallet',
                                      style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                                            color: Colors.black54,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    FilledButton(
                                      onPressed: () {
                                        ref.read(walletBalanceProvider.notifier).state += 500;
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Added ₹500 (demo)')),
                                        );
                                      },
                                      child: const Text('Add ₹500'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '₹$wallet',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
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
