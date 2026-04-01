import 'package:flutter/material.dart';

import '../data/models/order_models.dart';

/// Delivery milestones from [OrderRecord.placedAt] (matches [OrdersNotifier] timers).
abstract final class OrderDeliveryTimeline {
  static const int packedAfterSeconds = 30;
  static const int orderedAfterSeconds = 60;
  static const int deliveredAfterSeconds = 660; // 11 min total

  /// Matches [OrdersNotifier] timer thresholds — used after refresh / restore.
  static OrderStatus statusFromElapsedSincePlaced(Duration elapsed) {
    final s = elapsed.inSeconds;
    if (s >= deliveredAfterSeconds) return OrderStatus.delivered;
    if (s >= orderedAfterSeconds) return OrderStatus.ordered;
    if (s >= packedAfterSeconds) return OrderStatus.packed;
    return OrderStatus.placed;
  }

  static OrderRecord reconcileOrderClock(OrderRecord o, {DateTime? clock}) {
    final now = clock ?? DateTime.now();
    final next = statusFromElapsedSincePlaced(now.difference(o.placedAt));
    return o.copyWith(status: next);
  }

  /// Piecewise-linear 0→1 progress for a smooth live bar.
  static double smoothProgress(DateTime placedAt, {DateTime? clock}) {
    final now = clock ?? DateTime.now();
    final s = now.difference(placedAt).inMilliseconds / 1000.0;
    if (s >= deliveredAfterSeconds) return 1.0;
    if (s >= orderedAfterSeconds) {
      final span = (deliveredAfterSeconds - orderedAfterSeconds).toDouble();
      return 2 / 3 + (s - orderedAfterSeconds) / span * (1 / 3);
    }
    if (s >= packedAfterSeconds) {
      return 1 / 3 + (s - packedAfterSeconds) / (orderedAfterSeconds - packedAfterSeconds) * (1 / 3);
    }
    return (s / packedAfterSeconds) * (1 / 3);
  }

  /// Shown under the progress bar; updates every tick.
  static String liveDetailLine(DateTime placedAt, OrderStatus status, {DateTime? clock}) {
    if (status == OrderStatus.delivered) {
      return 'Delivered — thanks for ordering!';
    }
    final now = clock ?? DateTime.now();
    final s = now.difference(placedAt).inSeconds;
    if (s < packedAfterSeconds) {
      final left = packedAfterSeconds - s;
      return 'Next: Packed · in ${left}s';
    }
    if (s < orderedAfterSeconds) {
      final left = orderedAfterSeconds - s;
      return 'Next: Ordered · in ${left}s';
    }
    if (s < deliveredAfterSeconds) {
      final left = deliveredAfterSeconds - s;
      final m = left ~/ 60;
      final sec = left % 60;
      if (m > 0) {
        return 'Next: Delivered · in ${m}m ${sec}s';
      }
      return 'Next: Delivered · in ${sec}s';
    }
    return 'Finalizing delivery…';
  }

  /// Short line for order list tiles.
  static String liveListEta(DateTime placedAt, OrderStatus status, {DateTime? clock}) {
    if (status == OrderStatus.delivered) return 'Completed';
    final now = clock ?? DateTime.now();
    final s = now.difference(placedAt).inSeconds;
    if (s < packedAfterSeconds) return 'Packed in ${packedAfterSeconds - s}s';
    if (s < orderedAfterSeconds) return 'Ordered in ${orderedAfterSeconds - s}s';
    if (s < deliveredAfterSeconds) {
      final left = deliveredAfterSeconds - s;
      final m = left ~/ 60;
      final sec = left % 60;
      if (m > 0) return 'Delivered in ${m}m ${sec}s';
      return 'Delivered in ${sec}s';
    }
    return status.uiLabel;
  }
}

extension OrderStatusUi on OrderStatus {
  String get uiLabel => switch (this) {
        OrderStatus.placed => 'Placed',
        OrderStatus.packed => 'Packed',
        OrderStatus.ordered => 'Ordered',
        OrderStatus.delivered => 'Delivered',
      };

  IconData get uiIcon => switch (this) {
        OrderStatus.placed => Icons.check_circle_outline,
        OrderStatus.packed => Icons.inventory_2_outlined,
        OrderStatus.ordered => Icons.local_shipping_outlined,
        OrderStatus.delivered => Icons.done_all,
      };
}
