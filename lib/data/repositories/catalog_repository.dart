import '../models/mock_catalog.dart';
import '../models/product.dart';
import '../sources/mock_catalog_source.dart';

class CatalogRepository {
  CatalogRepository(this._source);

  final MockCatalogSource _source;

  Future<MockCatalog> getCatalog() => _source.load();

  Future<List<Product>> searchProducts(String query) async {
    final cat = await _source.load();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List<Product>.from(cat.products);
    return cat.products
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.unit.toLowerCase().contains(q) ||
              p.id.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<Product?> getProduct(String id) async {
    final cat = await _source.load();
    try {
      return cat.products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
