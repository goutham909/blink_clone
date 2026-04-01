import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../data/models/deal_card.dart';
import 'product_image_placeholder.dart';

class DealCardWidget extends StatelessWidget {
  const DealCardWidget({super.key, required this.deal, this.isLarge = false});

  final DealCardData deal;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final accent = deal.accentColor;
    final isLightCard = !isLarge && deal.isLightBackground;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          gradient: isLarge
              ? LinearGradient(
                  colors: [
                    accent,
                    accent.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isLarge ? null : (isLightCard ? Colors.white : kBlinkDarkCard),
          border: Border.all(color: Colors.white12),
        ),
        padding: const EdgeInsets.all(10),
        child: isLarge
            ? _LargeDealContent(deal: deal)
            : _SmallDealContent(deal: deal, isLightCard: isLightCard),
      ),
    );
  }
}

class _LargeDealContent extends StatelessWidget {
  const _LargeDealContent({required this.deal});

  final DealCardData deal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          deal.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          deal.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
              ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            deal.discountLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: deal.thumbnailHints.take(2).map((h) {
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: SizedBox(
                width: 48,
                height: 48,
                child: ProductImagePlaceholder(
                  imageHint: h,
                  accent: Colors.white,
                  height: 48,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SmallDealContent extends StatelessWidget {
  const _SmallDealContent({required this.deal, required this.isLightCard});

  final DealCardData deal;
  final bool isLightCard;

  @override
  Widget build(BuildContext context) {
    final titleColor = isLightCard ? Colors.black87 : Colors.white;
    final subColor = isLightCard ? Colors.black54 : Colors.white70;

    return LayoutBuilder(
      builder: (context, constraints) {
        final thumbnailHeight = (constraints.maxHeight * 0.28).clamp(24.0, 32.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.discountLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFFE11D48),
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Text(
                            deal.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: titleColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  height: 1.1,
                                ),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Flexible(
                          flex: 2,
                          child: Text(
                            deal.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: subColor,
                                  fontSize: 9,
                                  height: 1.1,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: thumbnailHeight,
              child: Row(
                children: deal.thumbnailHints.take(3).map((h) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: ProductImagePlaceholder(
                        imageHint: h,
                        accent: Theme.of(context).colorScheme.primary,
                        height: thumbnailHeight,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
