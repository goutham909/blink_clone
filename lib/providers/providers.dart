import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/address.dart';
import '../data/models/order_models.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/sources/mock_catalog_source.dart';

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
  @override
  List<OrderRecord> build() => [];

  void add(OrderRecord order) {
    state = [order, ...state];
  }

  void clear() => state = [];
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

/// User-typed recent searches (persisted in session).
class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void add(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final next = [q, ...state.where((s) => s.toLowerCase() != q.toLowerCase())];
    state = next.take(12).toList();
  }

  void clear() => state = [];
}

final recentSearchesNotifierProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(RecentSearchesNotifier.new);

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
