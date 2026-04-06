import 'package:flutter/material.dart';

import '../../core/constants.dart';

String formatInrAmount(int n) {
  final s = n.abs().toString();
  final parts = <String>[];
  var rest = s;
  while (rest.length > 3) {
    parts.insert(0, rest.substring(rest.length - 3));
    rest = rest.substring(0, rest.length - 3);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return parts.join(',');
}

class MoneyNoteSection extends StatelessWidget {
  const MoneyNoteSection({
    super.key,
    this.onReadTerms,
    this.bullets,
  });

  final VoidCallback? onReadTerms;
  final List<String>? bullets;

  static const _defaultBullets = [
    'Blinkit Money balance is valid for 1 year from the date of money added',
    'Blinkit Money is useable on Blinkit and Bistro',
    'Blinkit Money cannot be transferred to a bank account as per RBI guidelines.',
  ];

  @override
  Widget build(BuildContext context) {
    final items = bullets ?? _defaultBullets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOTE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: kBlinkMutedOnDark,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 10),
        ...items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(color: kBlinkMutedOnDark.withValues(alpha: 0.95), height: 1.35),
                ),
                Expanded(
                  child: isLast && onReadTerms != null
                      ? Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              e.value,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: kBlinkMutedOnDark,
                                    height: 1.35,
                                  ),
                            ),
                            GestureDetector(
                              onTap: onReadTerms,
                              child: Text(
                                ' Read T&Cs',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: kBlinkMoneyGreen,
                                      height: 1.35,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          e.value,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: kBlinkMutedOnDark,
                                height: 1.35,
                              ),
                        ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class MoneySegmentedToggle extends StatelessWidget {
  const MoneySegmentedToggle({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftSelected,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final bool leftSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegChip(
              label: leftLabel,
              selected: leftSelected,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _SegChip(
              label: rightLabel,
              selected: !leftSelected,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegChip extends StatelessWidget {
  const _SegChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? kBlinkMoneyGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.white54,
                ),
          ),
        ),
      ),
    );
  }
}

class SeamlessPaymentsFooter extends StatelessWidget {
  const SeamlessPaymentsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.white.withValues(alpha: 0.08), height: 32),
        Icon(Icons.account_balance_wallet_outlined, size: 40, color: Colors.white.withValues(alpha: 0.35)),
        const SizedBox(height: 10),
        Text(
          'Enjoy seamless single tap payments',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white54,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class MoneyCircleIconButton extends StatelessWidget {
  const MoneyCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2C2C2E),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
