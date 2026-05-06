import '../models/product_model.dart';

class RecommendationEngine {
  const RecommendationEngine();

  Future<List<ProductModel>> recommend({
    required List<ProductModel> products,
    required List<String> searchHistory,
    int limit = 8,
  }) async {
    if (products.isEmpty) return const [];
    return _fallback(products, limit, searchHistory);
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

  void dispose() {}
}
