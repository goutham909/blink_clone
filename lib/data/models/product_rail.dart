class ProductRail {
  const ProductRail({
    required this.id,
    required this.title,
    required this.productIds,
  });

  final String id;
  final String title;
  final List<String> productIds;

  factory ProductRail.fromJson(Map<String, dynamic> json) {
    return ProductRail(
      id: json['id'] as String,
      title: json['title'] as String,
      productIds: (json['productIds'] as List<dynamic>).cast<String>(),
    );
  }
}
