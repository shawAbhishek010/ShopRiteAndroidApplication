import '../models/product_model.dart';

class TrendingAlgorithm {
  List<ProductModel> calculateTrending(List<ProductModel> products) {
    final trending = [...products];
    trending.sort((a, b) {
      final aScore = _score(a);
      final bScore = _score(b);
      return bScore.compareTo(aScore);
    });
    return trending;
  }

  double _score(ProductModel product) {
    final stockSignal = product.isInStock ? 1 : -10;
    return (product.views * 0.35) +
        (product.addToCartCount * 0.55) +
        (product.rating * 12) +
        (product.discount * 0.25) +
        stockSignal;
  }
}
