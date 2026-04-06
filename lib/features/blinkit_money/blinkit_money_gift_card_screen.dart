import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import 'blinkit_money_widgets.dart';

class BlinkitMoneyGiftCardScreen extends StatefulWidget {
  const BlinkitMoneyGiftCardScreen({super.key});

  @override
  State<BlinkitMoneyGiftCardScreen> createState() => _BlinkitMoneyGiftCardScreenState();
}

class _BlinkitMoneyGiftCardScreenState extends State<BlinkitMoneyGiftCardScreen> {
  final _codeCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _hidePin = true;

  static const _noteBullets = [
    'You can claim gift cards worth up to ₹25,000 each month',
    'Gift card balance can be used on both Blinkit and Bistro',
    'Gift card amount will have the same expiry date as that of the gift card',
    'Claimed gift card cannot be transferred to another account',
  ];

  @override
  void dispose() {
    _codeCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlinkScreenBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GiftHeroHeader(
            onBack: () => Navigator.of(context).pop(),
            onFaq: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gift card FAQs (demo)')),
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: kBlinkElevatedSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Enter 16 digit code and the 6 digit PIN to claim your gift card',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: kBlinkMutedOnDark,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _codeCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDeco(context, 'Enter gift card code'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pinCtrl,
                          obscureText: _hidePin,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDeco(context, 'Enter pin').copyWith(
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _hidePin = !_hidePin),
                              icon: Icon(
                                _hidePin ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: kBlinkMoneyGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'NOTE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: kBlinkMutedOnDark,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 10),
                  ..._noteBullets.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: kBlinkMutedOnDark, height: 1.35)),
                          Expanded(
                            child: Text(
                              line,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: kBlinkMutedOnDark,
                                    height: 1.35,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kBlinkMutedOnDark),
                      children: [
                        const TextSpan(text: 'By continuing, you agree to our '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Terms & conditions (demo)')),
                              );
                            },
                            child: Text(
                              'Terms & Conditions',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: kBlinkMoneyGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gift card claim (demo)')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: kBlinkElevatedSurface,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _fieldDeco(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
      filled: true,
      fillColor: kBlinkScreenBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBlinkMoneyGreen, width: 1.5),
      ),
    );
  }
}

class _GiftHeroHeader extends StatelessWidget {
  const _GiftHeroHeader({
    required this.onBack,
    required this.onFaq,
  });

  final VoidCallback onBack;
  final VoidCallback onFaq;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4A3728),
            Color(0xFF2A2418),
            kBlinkScreenBg,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _MandalaHintPainter()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      MoneyCircleIconButton(icon: Icons.arrow_back_ios_new_rounded, onPressed: onBack),
                      const Spacer(),
                      TextButton(
                        onPressed: onFaq,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF2C2C2E),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('FAQ', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: -0.12,
                        child: _GiftBoxMini(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Gift Cards',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.rotate(
                        angle: 0.12,
                        child: _GiftBoxMini(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftBoxMini extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF8E1),
            kBlinkAmber,
            kBlinkMoneyGreen,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

class _MandalaHintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.72);
    for (var i = 0; i < 3; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withValues(alpha: 0.04 + i * 0.02);
      canvas.drawCircle(c, 40.0 + i * 36, paint);
    }
    final rnd = [12, 44, 78, 102, 130, 160, 188, 210, 240, 268];
    for (var i = 0; i < rnd.length; i++) {
      final x = rnd[i] / 280.0 * size.width;
      final y = 20.0 + (i * 17) % 50;
      canvas.drawCircle(
        Offset(x, y),
        1.1,
        Paint()..color = Colors.white.withValues(alpha: 0.07 + (i % 3) * 0.02),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
