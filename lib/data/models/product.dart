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
    this.rating = 4.2,
    this.ratingCount = 100,
    this.deliveryMinutes = 12,
    this.stockLeft,
    this.optionsCount = 0,
    this.boughtEarlier = false,
    this.isAd = false,
    this.isVegetarian = true,
  });

  final String id;
  final String name;
  final int mrp;
  final int salePrice;
  final String unit;
  final String categoryId;
  final String imageHint;
  final bool inStock;
  final double rating;
  final int ratingCount;
  final int deliveryMinutes;
  final int? stockLeft;
  final int optionsCount;
  final bool boughtEarlier;
  final bool isAd;
  final bool isVegetarian;

  int get discountPercent {
    if (mrp <= 0 || salePrice >= mrp) return 0;
    return (((mrp - salePrice) / mrp) * 100).round();
  }

  int get saveAmount => mrp > salePrice ? mrp - salePrice : 0;

  bool get isLowStock {
    if (!inStock) return false;
    final s = stockLeft;
    return s != null && s > 0 && s <= 5;
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
      rating: (json['rating'] as num?)?.toDouble() ?? 4.2,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 100,
      deliveryMinutes: (json['deliveryMinutes'] as num?)?.toInt() ?? 12,
      stockLeft: (json['stockLeft'] as num?)?.toInt(),
      optionsCount: (json['optionsCount'] as num?)?.toInt() ?? 0,
      boughtEarlier: json['boughtEarlier'] as bool? ?? false,
      isAd: json['isAd'] as bool? ?? false,
      isVegetarian: json['isVegetarian'] as bool? ?? true,
    );
  }
}
