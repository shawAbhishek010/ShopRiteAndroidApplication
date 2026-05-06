import 'package:firebase_core/firebase_core.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/firebase/firestore_service.dart';

class CartRepository {
  CartRepository({FirestoreService? firestoreService})
    : _firestoreService =
          firestoreService ??
          (Firebase.apps.isNotEmpty ? FirestoreService() : null);

  final FirestoreService? _firestoreService;
  final List<CartItemModel> _demoCart = [];

  bool get _firebaseReady => Firebase.apps.isNotEmpty;

  Stream<List<CartItemModel>> watchCart(String userId) {
    if (!_firebaseReady) return Stream<List<CartItemModel>>.value(_demoCart);

    return _firestoreService!.userDocument(userId).snapshots().map((snapshot) {
      final rawCart = snapshot.data()?['cart'] as List? ?? const [];
      return rawCart
          .map((item) => CartItemModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    });
  }

  Future<void> addProduct(String userId, ProductModel product) async {
    final current = await watchCart(userId).first;
    final next = [...current];
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
    final current = await watchCart(userId).first;
    final next = current
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

  Future<void> _saveCart(String userId, List<CartItemModel> items) async {
    if (!_firebaseReady) {
      _demoCart
        ..clear()
        ..addAll(items);
      return;
    }

    await _firestoreService!.userDocument(userId).update({
      'cart': items.map((item) => item.toMap()).toList(),
    });
  }
}
