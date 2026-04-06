import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import 'blinkit_money_widgets.dart';

class BlinkitMoneyHubScreen extends StatelessWidget {
  const BlinkitMoneyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlinkScreenBg,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: CustomPaint(
              painter: _GoldSpecklePainter(),
              child: const SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      MoneyCircleIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      MoneyCircleIconButton(
                        icon: Icons.settings_outlined,
                        onPressed: () => context.pushNamed('blinkitMoneySettings'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _WalletBrandBlock(),
                const SizedBox(height: 28),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FeatureCard(
                          icon: Icons.touch_app_rounded,
                          title: 'Single tap payments',
                          subtitle: 'Enjoy seamless payments without the wait for OTPs',
                        ),
                        const SizedBox(height: 12),
                        _FeatureCard(
                          icon: Icons.wifi_tethering_rounded,
                          title: 'Zero failures',
                          subtitle: 'Zero payment failures ensure you never miss an order',
                        ),
                        const SizedBox(height: 12),
                        _FeatureCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'Real-time refunds',
                          subtitle: 'No need to wait for refunds. Blinkit Money refunds are instant!',
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: () => context.pushNamed('blinkitMoneyAdd'),
                            style: FilledButton.styleFrom(
                              backgroundColor: kBlinkMoneyGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Add Money',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: kBlinkElevatedSurface,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => context.pushNamed('blinkitMoneyGiftCard'),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3A3A3C),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.card_giftcard_rounded,
                                        color: kBlinkAmber, size: 26),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Claim Gift Card',
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Enter gift card details to claim your gift card.',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: kBlinkMutedOnDark,
                                                height: 1.25,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: Colors.white38),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Text(
                    'Enjoy seamless one tap payments.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.06),
                          height: 1.2,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletBrandBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8C547),
                Color(0xFFC9A227),
                kBlinkMoneyGreen,
              ],
              stops: [0.0, 0.35, 1.0],
            ),
          ),
          child: const Center(
            child: Text(
              '₹',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'blinkit',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
        ),
        Text(
          'MONEY',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                height: 1.05,
                fontSize: 36,
              ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBlinkElevatedSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kBlinkAmber, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldSpecklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 48; i++) {
      final x = (size.width * ((i * 13) % 89 / 89.0));
      final y = (size.height * ((i * 7 + 3) % 73 / 73.0));
      final r = 0.8 + (i % 3) * 0.35;
      final paint = Paint()
        ..color = kBlinkAmber.withValues(alpha: 0.12 + (i % 5) * 0.02)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
