import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/constants.dart';
import '../models/mock_catalog.dart';

class MockCatalogSource {
  MockCatalog? _cache;

  Future<MockCatalog> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(mockCatalogAssetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    _cache = MockCatalog.fromJson(map);
    return _cache!;
  }

  /// For debug / tests: reload JSON from disk.
  Future<void> clearCache() async {
    _cache = null;
  }
}
