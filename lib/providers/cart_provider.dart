import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../repositories/cart_repository.dart';
import 'auth_provider.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartRepository? repository})
    : _repository = repository ?? CartRepository();

  final CartRepository _repository;
  StreamSubscription<List<CartItemModel>>? _subscription;

  List<CartItemModel> _items = [];
  ViewState _state = ViewState.idle;
  String? _userId;
  String? _message;

  List<CartItemModel> get items => List.unmodifiable(_items);
  ViewState get state => _state;
  String? get message => _message;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get discount => subtotal >= 3000 ? subtotal * 0.08 : 0;
  double get deliveryFee => subtotal >= 1499 || subtotal == 0 ? 0 : 79;
  double get total => subtotal - discount + deliveryFee;

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    _items = [];
    if (userId == null) {
      notifyListeners();
      return;
    }
    _subscription = _repository.watchCart(userId).listen((items) {
      _items = items;
      _state = ViewState.success;
      notifyListeners();
    });
  }

  Future<void> addProduct(ProductModel product) async {
    if (_userId == null) {
      _message = 'Please login to add items to cart.';
      notifyListeners();
      return;
    }
    await _repository.addProduct(_userId!, product);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (_userId == null) return;
    await _repository.updateQuantity(_userId!, productId, quantity);
  }

  Future<void> clear() async {
    if (_userId == null) return;
    await _repository.clear(_userId!);
  }

  void clearMessage() {
    _message = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
