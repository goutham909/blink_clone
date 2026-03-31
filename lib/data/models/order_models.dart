import 'product.dart';

enum OrderStatus { placed, packing, onWay, delivered }

class OrderLine {
  const OrderLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  int get lineTotal => product.salePrice * quantity;
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
}
