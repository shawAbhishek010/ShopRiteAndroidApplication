import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class RecommendationEngine {
  RecommendationEngine({http.Client? client, String? endpoint})
    : _client = client ?? http.Client(),
      _endpoint =
          endpoint ??
          const String.fromEnvironment(
            'RECOMMENDER_URL',
            defaultValue: 'http://127.0.0.1:8787/recommend',
          );

  final http.Client _client;
  final String _endpoint;

  Future<List<ProductModel>> recommend({
    required List<ProductModel> products,
    required List<String> searchHistory,
    int limit = 8,
  }) async {
    if (products.isEmpty) return const [];
    if (searchHistory.isEmpty) return _fallback(products, limit);

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'limit': limit,
              'searches': searchHistory,
              'products': products.map((product) => product.toMap()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _fallback(products, limit, searchHistory);
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final ids = (decoded['recommendations'] as List? ?? [])
          .map((item) => item.toString())
          .toList();
      final byId = {for (final product in products) product.id: product};
      final recommended = [
        for (final id in ids)
          if (byId[id] != null) byId[id]!,
      ];

      if (recommended.isEmpty) {
        return _fallback(products, limit, searchHistory);
      }
      return recommended.take(limit).toList();
    } catch (_) {
      return _fallback(products, limit, searchHistory);
    }
  }

  List<ProductModel> _fallback(
    List<ProductModel> products,
    int limit, [
    List<String> searchHistory = const [],
  ]) {
    final scored = [...products];
    scored.sort((a, b) {
      final aScore = _score(a, searchHistory);
      final bScore = _score(b, searchHistory);
      return bScore.compareTo(aScore);
    });
    return scored.take(limit).toList();
  }

  double _score(ProductModel product, List<String> searchHistory) {
    final haystack =
        '${product.name} ${product.category} ${product.description}'
            .toLowerCase();
    var searchBoost = 0.0;
    for (var index = 0; index < searchHistory.length; index++) {
      final query = searchHistory[index].toLowerCase();
      if (query.isEmpty) continue;
      final recencyBoost = 1 / (index + 1);
      for (final token in query.split(RegExp(r'\s+'))) {
        if (token.length < 2) continue;
        if (haystack.contains(token)) searchBoost += 3.5 * recencyBoost;
      }
    }

    final stockBoost = product.isInStock ? 0.6 : -5.0;
    final dealBoost = product.discount / 20;
    final behaviorBoost =
        (product.views * 0.01) + (product.addToCartCount * 0.03);
    return searchBoost +
        product.rating +
        stockBoost +
        dealBoost +
        behaviorBoost;
  }

  void dispose() {
    _client.close();
  }
}
