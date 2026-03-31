import 'banner_item.dart';
import 'category_chip.dart';
import 'product.dart';
import 'product_rail.dart';

class MockCatalog {
  const MockCatalog({
    required this.schemaVersion,
    required this.datasetId,
    required this.locationLabel,
    required this.banners,
    required this.categories,
    required this.rails,
    required this.products,
  });

  final int schemaVersion;
  final String datasetId;
  final String locationLabel;
  final List<BannerItem> banners;
  final List<CategoryChipData> categories;
  final List<ProductRail> rails;
  final List<Product> products;

  Map<String, Product> get productById {
    return {for (final p in products) p.id: p};
  }

  factory MockCatalog.fromJson(Map<String, dynamic> json) {
    return MockCatalog(
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      datasetId: json['datasetId'] as String,
      locationLabel: json['locationLabel'] as String? ?? 'Delivery to',
      banners: (json['banners'] as List<dynamic>)
          .map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => CategoryChipData.fromJson(e as Map<String, dynamic>))
          .toList(),
      rails: (json['rails'] as List<dynamic>)
          .map((e) => ProductRail.fromJson(e as Map<String, dynamic>))
          .toList(),
      products: (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
