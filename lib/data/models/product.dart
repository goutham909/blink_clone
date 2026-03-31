class Product {
  const Product({
    required this.id,
    required this.name,
    required this.mrp,
    required this.salePrice,
    required this.unit,
    required this.categoryId,
    required this.imageHint,
    required this.inStock,
  });

  final String id;
  final String name;
  final int mrp;
  final int salePrice;
  final String unit;
  final String categoryId;
  final String imageHint;
  final bool inStock;

  int get discountPercent {
    if (mrp <= 0 || salePrice >= mrp) return 0;
    return (((mrp - salePrice) / mrp) * 100).round();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      mrp: (json['mrp'] as num).toInt(),
      salePrice: (json['salePrice'] as num).toInt(),
      unit: json['unit'] as String,
      categoryId: json['categoryId'] as String,
      imageHint: json['imageHint'] as String? ?? 'misc',
      inStock: json['inStock'] as bool? ?? true,
    );
  }
}
