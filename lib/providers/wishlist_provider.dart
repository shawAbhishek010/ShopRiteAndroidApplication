import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/firebase/firestore_service.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider({FirestoreService? firestoreService})
    : _firestoreService =
          firestoreService ??
          (Firebase.apps.isNotEmpty ? FirestoreService() : null);

  final FirestoreService? _firestoreService;
  StreamSubscription<List<String>>? _subscription;
  final List<String> _demoWishlist = [];
  List<String> _wishlistIds = [];
  String? _userId;

  bool get _firebaseReady => Firebase.apps.isNotEmpty;
  List<String> get wishlistIds => List.unmodifiable(_wishlistIds);

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    if (userId == null) {
      _wishlistIds = [];
      notifyListeners();
      return;
    }
    if (!_firebaseReady) {
      _wishlistIds = _demoWishlist;
      notifyListeners();
      return;
    }
    _subscription = _firestoreService!
        .userDocument(userId)
        .snapshots()
        .map((doc) {
          return List<String>.from(
            doc.data()?['wishlist'] as List? ?? const [],
          );
        })
        .listen((ids) {
          _wishlistIds = ids;
          notifyListeners();
        });
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
    _wishlistIds = updated;
    notifyListeners();

    if (!_firebaseReady) {
      _demoWishlist
        ..clear()
        ..addAll(updated);
      return;
    }
    await _firestoreService!.userDocument(_userId!).update({
      'wishlist': updated,
    });
  }

  List<ProductModel> productsFrom(List<ProductModel> products) {
    return products
        .where((product) => _wishlistIds.contains(product.id))
        .toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
