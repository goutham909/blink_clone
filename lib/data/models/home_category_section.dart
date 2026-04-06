class HomeCategorySection {
  const HomeCategorySection({
    required this.categoryId,
    required this.title,
    this.subtitle,
    required this.productIds,
  });

  final String categoryId;
  final String title;
  final String? subtitle;
  final List<String> productIds;

  factory HomeCategorySection.fromJson(Map<String, dynamic> json) {
    return HomeCategorySection(
      categoryId: json['categoryId'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      productIds: (json['productIds'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }
}
