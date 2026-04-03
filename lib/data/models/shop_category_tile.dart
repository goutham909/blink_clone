/// Home “shop by category” tile (square image + label, Blinkit-style grid).
class ShopCategoryTile {
  const ShopCategoryTile({
    required this.label,
    required this.imageRef,
    this.categoryId,
    this.searchQuery,
  });

  final String label;
  final String imageRef;

  /// When set (and not [cat_all]), opens search scoped to this category.
  final String? categoryId;

  /// When non-empty, opens search with this query instead of [categoryId].
  final String? searchQuery;

  factory ShopCategoryTile.fromJson(Map<String, dynamic> json) {
    return ShopCategoryTile(
      label: json['label'] as String,
      imageRef: json['imageRef'] as String,
      categoryId: json['categoryId'] as String?,
      searchQuery: json['searchQuery'] as String?,
    );
  }
}
