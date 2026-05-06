import 'package:flutter/foundation.dart';

import '../models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final Map<String, List<String>> _wishlistByUser = {};

  List<String> _wishlistIds = [];
  String? _userId;

  List<String> get wishlistIds => List.unmodifiable(_wishlistIds);

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _wishlistIds = userId == null
        ? []
        : List<String>.from(_wishlistByUser[userId] ?? const []);
    notifyListeners();
  }

  bool contains(String productId) => _wishlistIds.contains(productId);

  Future<void> toggle(ProductModel product) async {
    if (_userId == null) return;
    final updated = [..._wishlistIds];
    if (updated.contains(product.id)) {
      updated.remove(product.id);
    } else {
      updated.add(product.id);
    }
    _wishlistByUser[_userId!] = List.unmodifiable(updated);
    _wishlistIds = updated;
    notifyListeners();
  }

  List<ProductModel> productsFrom(List<ProductModel> products) {
    return products
        .where((product) => _wishlistIds.contains(product.id))
        .toList();
  }
}
