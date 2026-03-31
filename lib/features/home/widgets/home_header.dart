import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../providers/providers.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    required this.locationTitle,
    required this.deliveryMinutes,
    required this.onLocationTap,
  });

  final String locationTitle;
  final int deliveryMinutes;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletBalanceProvider);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFE066),
            Color(0xFFFFD54F),
            Color(0xFFFFF8E1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
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
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          '$deliveryMinutes minutes',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
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
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kBlinkGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.black12,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => context.pushNamed('account'),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.person_outline, color: Colors.black87),
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
