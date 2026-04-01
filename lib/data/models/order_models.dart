import 'product.dart';

/// Checkout tracking: advances on timers after place order (see [OrdersNotifier]).
enum OrderStatus { placed, packed, ordered, delivered }

OrderStatus orderStatusFromStorage(String name) {
  return OrderStatus.values.firstWhere(
    (e) => e.name == name,
    orElse: () => OrderStatus.placed,
  );
}

class OrderLine {
  const OrderLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  int get lineTotal => product.salePrice * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    return OrderLine(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.placedAt,
    required this.lines,
    required this.deliveryFee,
    required this.addressSummary,
    required this.paymentLabel,
    required this.status,
  });

  final String id;
  final DateTime placedAt;
  final List<OrderLine> lines;
  final int deliveryFee;
  final String addressSummary;
  final String paymentLabel;
  final OrderStatus status;

  int get subtotal => lines.fold(0, (a, b) => a + b.lineTotal);
  int get total => subtotal + deliveryFee;

  OrderRecord copyWith({OrderStatus? status}) {
    return OrderRecord(
      id: id,
      placedAt: placedAt,
      lines: lines,
      deliveryFee: deliveryFee,
      addressSummary: addressSummary,
      paymentLabel: paymentLabel,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'placedAt': placedAt.toIso8601String(),
        'lines': lines.map((e) => e.toJson()).toList(),
        'deliveryFee': deliveryFee,
        'addressSummary': addressSummary,
        'paymentLabel': paymentLabel,
        'status': status.name,
      };

  factory OrderRecord.fromJson(Map<String, dynamic> json) {
    return OrderRecord(
      id: json['id'] as String,
      placedAt: DateTime.parse(json['placedAt'] as String),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      deliveryFee: (json['deliveryFee'] as num).toInt(),
      addressSummary: json['addressSummary'] as String,
      paymentLabel: json['paymentLabel'] as String,
      status: orderStatusFromStorage(json['status'] as String? ?? 'placed'),
    );
  }
}
