import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../providers/providers.dart';
import 'blinkit_money_widgets.dart';

class BlinkitMoneyAddScreen extends ConsumerStatefulWidget {
  const BlinkitMoneyAddScreen({super.key});

  @override
  ConsumerState<BlinkitMoneyAddScreen> createState() => _BlinkitMoneyAddScreenState();
}

class _BlinkitMoneyAddScreenState extends ConsumerState<BlinkitMoneyAddScreen> {
  /// true = Auto add, false = Add once
  bool _autoAdd = true;
  int _amount = 2000;
  int _threshold = 500;

  void _showTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms & conditions (demo)')),
    );
  }

  void _pickThreshold() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kBlinkDarkCard,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'When balance goes below',
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              ...[100, 200, 500, 1000].map(
                (v) => ListTile(
                  title: Text('₹${formatInrAmount(v)}', style: const TextStyle(color: Colors.white)),
                  trailing: _threshold == v ? const Icon(Icons.check, color: kBlinkMoneyGreen) : null,
                  onTap: () {
                    setState(() => _threshold = v);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAddPaymentMethod() {
    ref.read(walletBalanceProvider.notifier).state += _amount;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ₹${formatInrAmount(_amount)} to wallet (demo)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlinkScreenBg,
      appBar: AppBar(
        backgroundColor: kBlinkScreenBg,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Add money',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: MoneySegmentedToggle(
              leftLabel: 'Auto add',
              rightLabel: 'Add once',
              leftSelected: _autoAdd,
              onChanged: (v) => setState(() => _autoAdd = v),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_autoAdd) _AutoAddCard(threshold: _threshold, amount: _amount, onThresholdTap: _pickThreshold),
                  if (!_autoAdd) _AddOnceCard(amount: _amount, onSelect: (v) => setState(() => _amount = v)),
                  const SizedBox(height: 24),
                  MoneyNoteSection(onReadTerms: _showTerms),
                  const SizedBox(height: 8),
                  const SeamlessPaymentsFooter(),
                  if (!_autoAdd) const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _autoAdd ? _AutoBottomBar(onPressed: _onAddPaymentMethod) : _AddOnceBottomBar(amount: _amount, onAdd: _onAddPaymentMethod),
    );
  }
}

class _AutoAddCard extends StatelessWidget {
  const _AutoAddCard({
    required this.threshold,
    required this.amount,
    required this.onThresholdTap,
  });

  final int threshold;
  final int amount;
  final VoidCallback onThresholdTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: kBlinkElevatedSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Automatically add',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kBlinkMutedOnDark),
          ),
          const SizedBox(height: 12),
          Text(
            '₹ ${formatInrAmount(amount)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 34,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Text(
                'when balance goes below ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kBlinkMutedOnDark),
              ),
              GestureDetector(
                onTap: onThresholdTap,
                child: Text(
                  '₹ ${formatInrAmount(threshold)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: kBlinkMoneyGreen,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dotted,
                        decorationColor: kBlinkMoneyGreen,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddOnceCard extends StatelessWidget {
  const _AddOnceCard({
    required this.amount,
    required this.onSelect,
  });

  final int amount;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter amount to add',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kBlinkMutedOnDark),
        ),
        const SizedBox(height: 12),
        Text(
          '₹ ${formatInrAmount(amount)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 34,
              ),
        ),
        const SizedBox(height: 20),
        Row(
          children: _AddOnceCard._presets.map((p) {
            final sel = p == amount;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: p == 10000 ? 0 : 8),
                child: Material(
                  color: sel ? kBlinkMoneyChipSelectedBg : kBlinkElevatedSurface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => onSelect(p),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? kBlinkMoneyGreen : Colors.white24,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '₹${formatInrAmount(p)}',
                        style: TextStyle(
                          color: sel ? kBlinkMoneyGreen : Colors.white54,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static const _presets = [2000, 5000, 10000];
}

class _AutoBottomBar extends StatelessWidget {
  const _AutoBottomBar({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: kBlinkMoneyGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Add Payment Method', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddOnceBottomBar extends StatelessWidget {
  const _AddOnceBottomBar({
    required this.amount,
    required this.onAdd,
  });

  final int amount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final formatted = formatInrAmount(amount);
    return Material(
      color: kBlinkScreenBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PAY USING',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: kBlinkMutedOnDark,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: kBlinkMutedOnDark),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BAF2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'P',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Paytm UPI',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: kBlinkMoneyGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹$formatted.00',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Add money',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.play_arrow_rounded, size: 18),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
