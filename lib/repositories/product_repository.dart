import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/product_model.dart';
import '../services/api/product_api.dart';
import '../services/firebase/firestore_service.dart';
import '../services/local/cache_service.dart';

class ProductRepository {
  ProductRepository({
    ProductApi? productApi,
    FirestoreService? firestoreService,
    CacheService? cacheService,
  }) : _productApi = productApi ?? ProductApi(),
       _firestoreService =
           firestoreService ??
           (Firebase.apps.isNotEmpty ? FirestoreService() : null),
       _cacheService = cacheService ?? CacheService();

  final ProductApi _productApi;
  final FirestoreService? _firestoreService;
  final CacheService _cacheService;

  bool get _firebaseReady => Firebase.apps.isNotEmpty;

  Stream<List<ProductModel>> watchProducts() {
    if (!_firebaseReady) {
      return Stream<List<ProductModel>>.fromFuture(_loadDemoProducts());
    }

    return _firestoreService!.productsQuery().snapshots().asyncMap((
      snapshot,
    ) async {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
      if (products.isEmpty) {
        return _loadDemoProducts();
      }

      await _cacheService.cacheProducts(products);
      return products;
    });
  }

  Future<List<ProductModel>> getCachedProducts() =>
      _cacheService.readCachedProducts();

  Future<void> trackProductView(String productId) async {
    await _cacheService.addRecentlyViewed(productId);
    if (!_firebaseReady) return;

    try {
      await _firestoreService!.collection('products').doc(productId).update({
        'views': FieldValue.increment(1),
      });
    } on FirebaseException catch (error) {
      if (error.code != 'not-found') rethrow;
    }
  }

  Future<void> trackAddToCart(String productId) async {
    if (!_firebaseReady) return;

    try {
      await _firestoreService!.collection('products').doc(productId).update({
        'addToCartCount': FieldValue.increment(1),
      });
    } on FirebaseException catch (error) {
      if (error.code != 'not-found') rethrow;
    }
  }

  Future<void> createProduct(ProductModel product) async {
    if (_firebaseReady) {
      await _firestoreService!
          .collection('products')
          .doc(product.id)
          .set(product.toMap());
      return;
    }

    final products = await _loadDemoProducts();
    await _cacheService.cacheProducts([product, ...products]);
  }

  Future<void> updateProduct(ProductModel product) async {
    if (_firebaseReady) {
      await _firestoreService!
          .collection('products')
          .doc(product.id)
          .set(product.toMap(), SetOptions(merge: true));
      return;
    }

    final products = await _loadDemoProducts();
    await _cacheService.cacheProducts([
      for (final item in products)
        if (item.id == product.id) product else item,
    ]);
  }

  Future<void> deleteProduct(String productId) async {
    if (_firebaseReady) {
      await _firestoreService!.collection('products').doc(productId).delete();
      return;
    }

    final products = await _loadDemoProducts();
    await _cacheService.cacheProducts([
      for (final product in products)
        if (product.id != productId) product,
    ]);
  }

  Future<List<ProductModel>> recentlyViewed(
    List<ProductModel> allProducts,
  ) async {
    final ids = await _cacheService.readRecentlyViewedIds();
    final viewed = <ProductModel>[];
    for (final id in ids) {
      for (final product in allProducts) {
        if (product.id == id) {
          viewed.add(product);
          break;
        }
      }
    }
    return viewed;
  }

  Future<List<String>> recordSearch(String query) {
    return _cacheService.addSearchQuery(query);
  }

  Future<List<String>> searchHistory() {
    return _cacheService.readSearchHistory();
  }

  Future<List<ProductModel>> _loadDemoProducts() async {
    final cached = await _cacheService.readCachedProducts();
    if (cached.isNotEmpty) return cached;
    final demoProducts = await _productApi.fetchProducts();
    await _cacheService.cacheProducts(demoProducts);
    return demoProducts;
  }
}
