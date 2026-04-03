import 'address.dart';
import 'banner_item.dart';
import 'category_chip.dart';
import 'deal_card.dart';
import 'product.dart';
import 'product_rail.dart';
import 'recent_search.dart';
import 'shop_category_tile.dart';

class MockCatalog {
  const MockCatalog({
    required this.schemaVersion,
    required this.datasetId,
    required this.locationLabel,
    required this.deliveryMinutes,
    required this.banners,
    required this.categories,
    required this.rails,
    required this.products,
    required this.poweredBy,
    required this.dealCards,
    required this.recentSearches,
    required this.trendingProductIds,
    required this.savedAddresses,
    required this.currentLocationAddress,
    required this.recommendationBrand,
    this.shopCategoryTiles = const [],
  });

  final int schemaVersion;
  final String datasetId;
  final String locationLabel;
  final int deliveryMinutes;
  final List<BannerItem> banners;
  final List<CategoryChipData> categories;
  final List<ProductRail> rails;
  final List<Product> products;
  final List<String> poweredBy;
  final List<DealCardData> dealCards;
  final List<RecentSearchEntry> recentSearches;
  final List<String> trendingProductIds;
  final List<SavedAddress> savedAddresses;
  final String currentLocationAddress;
  final String recommendationBrand;
  final List<ShopCategoryTile> shopCategoryTiles;

  Map<String, Product> get productById {
    return {for (final p in products) p.id: p};
  }

  factory MockCatalog.fromJson(Map<String, dynamic> json) {
    return MockCatalog(
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      datasetId: json['datasetId'] as String,
      locationLabel: json['locationLabel'] as String? ?? 'Delivery to',
      deliveryMinutes: (json['deliveryMinutes'] as num?)?.toInt() ?? 12,
      banners: (json['banners'] as List<dynamic>?)
              ?.map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      categories: (json['categories'] as List<dynamic>)
          .map((e) => CategoryChipData.fromJson(e as Map<String, dynamic>))
          .toList(),
      rails: (json['rails'] as List<dynamic>)
          .map((e) => ProductRail.fromJson(e as Map<String, dynamic>))
          .toList(),
      products: (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      poweredBy: (json['poweredBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dealCards: (json['dealCards'] as List<dynamic>?)
              ?.map((e) => DealCardData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentSearches: (json['recentSearches'] as List<dynamic>?)
              ?.map((e) => RecentSearchEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      trendingProductIds: (json['trendingProductIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      savedAddresses: (json['savedAddresses'] as List<dynamic>?)
              ?.map((e) => SavedAddress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentLocationAddress: json['currentLocationAddress'] as String? ??
          'The Skyview, Raidurgam, Hitech City Main Rd, Madhapur, Telangana',
      recommendationBrand: json['recommendationBrand'] as String? ?? 'Kwality Walls',
      shopCategoryTiles: (json['shopCategoryTiles'] as List<dynamic>?)
              ?.map((e) => ShopCategoryTile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
