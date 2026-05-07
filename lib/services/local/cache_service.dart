import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/product_model.dart';
//CacheService is responsible for caching product data, recently viewed products, and search history using SharedPreferences. It provides methods to store and retrieve this data, allowing the app to function more efficiently and provide a better user experience even when offline.
class CacheService {
  static const _productsKey = 'cached_products_v5';
  static const _recentlyViewedKey = 'recently_viewed_products';
  static const _searchHistoryKey = 'product_search_history';

  Future<void> cacheProducts(List<ProductModel> products) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(products.map((item) => item.toMap()).toList());
    await preferences.setString(_productsKey, encoded);
  }

  Future<List<ProductModel>> readCachedProducts() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_productsKey);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map(
          (item) => ProductModel.fromMap(
            Map<String, dynamic>.from(item),
            item['id'] as String? ?? '',
          ),
        )
        .toList();
  }

  Future<void> addRecentlyViewed(String productId) async {
    final preferences = await SharedPreferences.getInstance();
    final current = preferences.getStringList(_recentlyViewedKey) ?? [];
    final updated = [
      productId,
      ...current.where((id) => id != productId),
    ].take(10).toList();
    await preferences.setStringList(_recentlyViewedKey, updated);
  }

  Future<List<String>> readRecentlyViewedIds() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_recentlyViewedKey) ?? [];
  }

  Future<List<String>> addSearchQuery(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.length < 2) return readSearchHistory();

    final preferences = await SharedPreferences.getInstance();
    final current = preferences.getStringList(_searchHistoryKey) ?? [];
    final updated = [normalized, ...current].take(30).toList();
    await preferences.setStringList(_searchHistoryKey, updated);
    return updated;
  }

  Future<List<String>> readSearchHistory() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_searchHistoryKey) ?? [];
  }
}
