import 'package:flutter/material.dart';

import '../../../data/models/deal_card.dart';
import '../../../widgets/deal_card_widget.dart';

class DealCardsGrid extends StatelessWidget {
  const DealCardsGrid({super.key, required this.deals});

  final List<DealCardData> deals;

  @override
  Widget build(BuildContext context) {
    if (deals.isEmpty) return const SizedBox.shrink();

    final large = deals.first;
    final small = deals.length > 1 ? deals.sublist(1) : <DealCardData>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gridHeight = (constraints.maxWidth * 0.58).clamp(232.0, 296.0);
          return SizedBox(
            height: gridHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: DealCardWidget(deal: large, isLarge: true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: small.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: small.isNotEmpty
                                        ? DealCardWidget(deal: small[0])
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: small.length > 1
                                        ? DealCardWidget(deal: small[1])
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: small.length > 2
                                        ? DealCardWidget(deal: small[2])
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: small.length > 3
                                        ? DealCardWidget(deal: small[3])
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
