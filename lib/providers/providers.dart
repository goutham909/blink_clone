import 'dart:async';
import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/order_delivery_timeline.dart';
import '../data/models/address.dart';
import '../data/models/order_models.dart';
import '../data/models/product.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/sources/mock_catalog_source.dart';

/// Overridden in [main] after `SharedPreferences.getInstance()`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('sharedPreferencesProvider must be overridden in main()');
});

const _ordersPrefsKey = 'blink_clone_orders_v1';
const _maxPersistedOrders = 3;

final mockCatalogSourceProvider = Provider<MockCatalogSource>((ref) {
  return MockCatalogSource();
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(mockCatalogSourceProvider));
});

final catalogProvider = FutureProvider((ref) async {
  return ref.watch(catalogRepositoryProvider).getCatalog();
});

class CartLine {
  const CartLine({required this.productId, required this.quantity});

  final String productId;
  final int quantity;
}

class CartNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void setQuantity(String productId, int qty) {
    final next = Map<String, int>.from(state);
    if (qty <= 0) {
      next.remove(productId);
    } else {
      next[productId] = qty;
    }
    state = next;
  }

  void addOne(String productId) {
    final q = state[productId] ?? 0;
    setQuantity(productId, q + 1);
  }

  void removeOne(String productId) {
    final q = state[productId] ?? 0;
    setQuantity(productId, q - 1);
  }

  void clear() => state = {};
}

final cartProvider = NotifierProvider<CartNotifier, Map<String, int>>(
  CartNotifier.new,
);

final cartLinesProvider = Provider<List<CartLine>>((ref) {
  final map = ref.watch(cartProvider);
  return map.entries
      .map((e) => CartLine(productId: e.key, quantity: e.value))
      .toList();
});

class OrdersNotifier extends Notifier<List<OrderRecord>> {
  final Map<String, List<Timer>> _timersByOrderId = {};

  @override
  List<OrderRecord> build() {
    ref.onDispose(() {
      for (final list in _timersByOrderId.values) {
        for (final t in list) {
          t.cancel();
        }
      }
      _timersByOrderId.clear();
    });

    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(_ordersPrefsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final loaded = decoded
          .map((e) => OrderRecord.fromJson(e as Map<String, dynamic>))
          .map(OrderDeliveryTimeline.reconcileOrderClock)
          .take(_maxPersistedOrders)
          .toList();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        for (final o in loaded) {
          _scheduleStatusProgression(o.id);
        }
        _persistOrders();
      });
      return loaded;
    } catch (_) {
      return [];
    }
  }

  void _persistOrders() {
    final prefs = ref.read(sharedPreferencesProvider);
    final snapshot = List<OrderRecord>.from(state);
    unawaited(_writeOrdersPrefs(prefs, snapshot));
  }

  static Future<void> _writeOrdersPrefs(
    SharedPreferences prefs,
    List<OrderRecord> orders,
  ) async {
    try {
      final payload = jsonEncode(orders.map((e) => e.toJson()).toList());
      await prefs.setString(_ordersPrefsKey, payload);
    } catch (_) {}
  }

  void _cancelTimers(String orderId) {
    _timersByOrderId[orderId]?.forEach((t) => t.cancel());
    _timersByOrderId.remove(orderId);
  }

  void add(OrderRecord order) {
    final next = [order, ...state].take(_maxPersistedOrders).toList();
    final kept = next.map((o) => o.id).toSet();
    for (final id in state.map((o) => o.id)) {
      if (!kept.contains(id)) _cancelTimers(id);
    }
    state = next;
    _scheduleStatusProgression(order.id);
    _persistOrders();
  }

  /// Packed at 30s, ordered at 1 min, delivered at 11 min from [OrderRecord.placedAt].
  void _scheduleStatusProgression(String orderId) {
    _cancelTimers(orderId);

    var idx = state.indexWhere((o) => o.id == orderId);
    if (idx < 0) return;

    final reconciled = OrderDeliveryTimeline.reconcileOrderClock(state[idx]);
    if (reconciled.status != state[idx].status) {
      state = [
        ...state.sublist(0, idx),
        reconciled,
        ...state.sublist(idx + 1),
      ];
      _persistOrders();
      idx = state.indexWhere((o) => o.id == orderId);
    }

    final order = state[idx];
    if (order.status == OrderStatus.delivered) return;

    final placed = order.placedAt;
    final now = DateTime.now();

    Duration delayUntil(DateTime milestone) {
      final d = milestone.difference(now);
      return d.isNegative ? Duration.zero : d;
    }

    void bump(OrderStatus status) {
      final i = state.indexWhere((o) => o.id == orderId);
      if (i < 0) return;
      if (OrderStatus.values.indexOf(state[i].status) >= OrderStatus.values.indexOf(status)) {
        return;
      }
      state = [
        ...state.sublist(0, i),
        state[i].copyWith(status: status),
        ...state.sublist(i + 1),
      ];
      _persistOrders();
    }

    final milestones = <(OrderStatus, DateTime)>[
      (OrderStatus.packed, placed.add(const Duration(seconds: OrderDeliveryTimeline.packedAfterSeconds))),
      (OrderStatus.ordered, placed.add(const Duration(seconds: OrderDeliveryTimeline.orderedAfterSeconds))),
      (OrderStatus.delivered, placed.add(const Duration(seconds: OrderDeliveryTimeline.deliveredAfterSeconds))),
    ];

    final timers = <Timer>[];
    final currentRank = OrderStatus.values.indexOf(order.status);
    for (final (target, at) in milestones) {
      if (currentRank >= OrderStatus.values.indexOf(target)) continue;
      timers.add(Timer(delayUntil(at), () => bump(target)));
    }
    _timersByOrderId[orderId] = timers;
  }

  void clear() {
    for (final list in _timersByOrderId.values) {
      for (final t in list) {
        t.cancel();
      }
    }
    _timersByOrderId.clear();
    state = [];
    unawaited(
      ref.read(sharedPreferencesProvider).remove(_ordersPrefsKey),
    );
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<OrderRecord>>(
  OrdersNotifier.new,
);

typedef CartTotals = ({int itemCount, int subtotal});

final cartTotalsProvider = Provider<CartTotals>((ref) {
  final cart = ref.watch(cartProvider);
  final catalogAsync = ref.watch(catalogProvider);
  final catalog = catalogAsync.valueOrNull;
  if (catalog == null || cart.isEmpty) {
    return (itemCount: 0, subtotal: 0);
  }
  final byId = catalog.productById;
  var count = 0;
  var subtotal = 0;
  for (final e in cart.entries) {
    final p = byId[e.key];
    if (p != null && p.inStock) {
      count += e.value;
      subtotal += p.salePrice * e.value;
    }
  }
  return (itemCount: count, subtotal: subtotal);
});

/// User-typed recent searches (session) + whether mock catalog seeds stay visible.
class RecentSearchesUiState {
  const RecentSearchesUiState({
    this.queries = const [],
    this.hideCatalogRecent = false,
  });

  final List<String> queries;
  /// When true, "Recent searches" omits JSON mock entries (after user taps Clear).
  final bool hideCatalogRecent;

  RecentSearchesUiState copyWith({
    List<String>? queries,
    bool? hideCatalogRecent,
  }) =>
      RecentSearchesUiState(
        queries: queries ?? this.queries,
        hideCatalogRecent: hideCatalogRecent ?? this.hideCatalogRecent,
      );
}

class RecentSearchesNotifier extends Notifier<RecentSearchesUiState> {
  @override
  RecentSearchesUiState build() => const RecentSearchesUiState();

  void add(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final next = [q, ...state.queries.where((s) => s.toLowerCase() != q.toLowerCase())];
    state = state.copyWith(queries: next.take(12).toList());
  }

  void clear() => state = const RecentSearchesUiState(
        queries: [],
        hideCatalogRecent: true,
      );
}

final recentSearchesNotifierProvider =
    NotifierProvider<RecentSearchesNotifier, RecentSearchesUiState>(RecentSearchesNotifier.new);

/// Selected delivery address label + line (mock).
class SelectedAddressNotifier extends Notifier<SavedAddress?> {
  @override
  SavedAddress? build() => null;

  void select(SavedAddress? address) => state = address;
}

final selectedAddressProvider =
    NotifierProvider<SelectedAddressNotifier, SavedAddress?>(SelectedAddressNotifier.new);

/// Mock wallet balance shown in header (₹).
final walletBalanceProvider = StateProvider<int>((ref) => 0);

/// Account → Appearance (drives app theme).
final appearanceDarkProvider = StateProvider<bool>((ref) => true);

/// Account → hide sensitive categories (e.g. pharma) on home & search.
final hideSensitiveProvider = StateProvider<bool>((ref) => false);

class WishlistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String productId) {
    final next = Set<String>.from(state);
    if (next.contains(productId)) {
      next.remove(productId);
    } else {
      next.add(productId);
    }
    state = next;
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, Set<String>>(
  WishlistNotifier.new,
);

bool visibleWithSensitiveFilter(Product p, bool hideSensitive) {
  if (!hideSensitive) return true;
  return !p.isSensitiveCategory;
}
