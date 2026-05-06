import 'dart:async';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartRepository {
  final Map<String, List<CartItemModel>> _cartsByUser = {};
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  Stream<List<CartItemModel>> watchCart(String userId) async* {
    yield _cartForUser(userId);
    yield* _controller.stream
        .where((changedUserId) => changedUserId == userId)
        .map((_) => _cartForUser(userId));
  }

  Future<void> addProduct(String userId, ProductModel product) async {
    final next = _cartForUser(userId).toList();
    final index = next.indexWhere((item) => item.productId == product.id);
    if (index == -1) {
      next.add(CartItemModel.fromProduct(product));
    } else {
      next[index] = next[index].copyWith(quantity: next[index].quantity + 1);
    }
    await _saveCart(userId, next);
  }

  Future<void> updateQuantity(
    String userId,
    String productId,
    int quantity,
  ) async {
    final next = _cartForUser(userId)
        .where((item) => item.productId != productId || quantity > 0)
        .map(
          (item) => item.productId == productId
              ? item.copyWith(quantity: quantity)
              : item,
        )
        .toList();
    await _saveCart(userId, next);
  }

  Future<void> clear(String userId) => _saveCart(userId, const []);

  List<CartItemModel> _cartForUser(String userId) {
    return List.unmodifiable(_cartsByUser[userId] ?? const []);
  }

  Future<void> _saveCart(String userId, List<CartItemModel> items) async {
    _cartsByUser[userId] = List.unmodifiable(items);
    if (!_controller.isClosed) {
      _controller.add(userId);
    }
  }
}
