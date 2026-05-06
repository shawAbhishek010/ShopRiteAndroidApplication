import 'dart:async';

import 'package:flutter/foundation.dart';

import '../logic/recommendation_engine.dart';
import '../logic/trending_algorithm.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../core/utils/network_checker.dart';
import 'auth_provider.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({
    ProductRepository? repository,
    NetworkChecker? networkChecker,
    RecommendationEngine? recommendationEngine,
    TrendingAlgorithm? trendingAlgorithm,
  }) : _repository = repository ?? ProductRepository(),
       _networkChecker = networkChecker ?? NetworkChecker(),
       _recommendationEngine = recommendationEngine ?? RecommendationEngine(),
       _trendingAlgorithm = trendingAlgorithm ?? TrendingAlgorithm() {
    _networkSubscription = _networkChecker.onStatusChanged.listen((online) {
      _isOnline = online;
      notifyListeners();
    });
  }

  final ProductRepository _repository;
  final NetworkChecker _networkChecker;
  final RecommendationEngine _recommendationEngine;
  final TrendingAlgorithm _trendingAlgorithm;

  StreamSubscription<List<ProductModel>>? _productSubscription;
  StreamSubscription<bool>? _networkSubscription;
  Timer? _searchHistoryDebounce;

  static const pageSize = 20;

  List<ProductModel> _products = [];
  List<ProductModel> _recentlyViewed = [];
  List<ProductModel> _recommendations = [];
  List<String> _searchHistory = [];
  ViewState _state = ViewState.idle;
  String _searchQuery = '';
  String? _selectedCategory;
  int _visibleProductCount = pageSize;
  bool _isOnline = true;
  String? _errorMessage;
  int _recommendationRequest = 0;

  List<ProductModel> get products => List.unmodifiable(_products);
  ViewState get state => _state;
  bool get isOnline => _isOnline;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  List<ProductModel> get recentlyViewed => List.unmodifiable(_recentlyViewed);
  List<ProductModel> get recommendations => List.unmodifiable(_recommendations);
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  List<String> get categories {
    final values = _products
        .map((product) => product.category)
        .toSet()
        .toList();
    values.sort();
    return values;
  }

  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == null || product.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<ProductModel> get visibleFilteredProducts {
    return filteredProducts.take(_visibleProductCount).toList();
  }

  bool get canLoadMore => _visibleProductCount < filteredProducts.length;

  int get remainingProductCount {
    final remaining = filteredProducts.length - _visibleProductCount;
    return remaining < 0 ? 0 : remaining;
  }

  List<ProductModel> get homeSearchResults {
    if (_searchQuery.trim().isEmpty) return const [];
    return filteredProducts.take(8).toList();
  }

  List<ProductModel> get trendingProducts {
    return _trendingAlgorithm.calculateTrending(_products).take(6).toList();
  }

  void loadProducts() {
    _state = ViewState.loading;
    notifyListeners();
    _productSubscription?.cancel();
    _productSubscription = _repository.watchProducts().listen(
      (products) async {
        _products = products;
        _recentlyViewed = await _repository.recentlyViewed(products);
        _searchHistory = await _repository.searchHistory();
        _state = ViewState.success;
        _errorMessage = null;
        notifyListeners();
        unawaited(_refreshRecommendations());
      },
      onError: (Object error) async {
        _isOnline = await _networkChecker.isConnected;
        _products = await _repository.getCachedProducts();
        _searchHistory = await _repository.searchHistory();
        _state = _products.isEmpty ? ViewState.error : ViewState.success;
        _errorMessage = _products.isEmpty
            ? 'Products could not be loaded. Check your connection.'
            : 'You are offline. Showing cached products.';
        notifyListeners();
        unawaited(_refreshRecommendations());
      },
    );
  }

  void updateSearch(String value) {
    _searchQuery = value.trim();
    if (_searchQuery.isNotEmpty) {
      _selectedCategory = null;
      _queueSearchHistoryUpdate(_searchQuery);
    } else {
      _searchHistoryDebounce?.cancel();
    }
    _visibleProductCount = pageSize;
    notifyListeners();
  }

  void submitSearch() {
    _searchHistoryDebounce?.cancel();
    if (_searchQuery.length >= 2) {
      unawaited(_recordSearch(_searchQuery));
    }
  }

  void selectCategory(String? category) {
    _selectedCategory = category;
    _searchQuery = '';
    _visibleProductCount = pageSize;
    notifyListeners();
  }

  void loadMoreProducts() {
    _visibleProductCount += pageSize;
    notifyListeners();
  }

  Future<void> trackProductView(ProductModel product) async {
    await _repository.trackProductView(product.id);
    _recentlyViewed = await _repository.recentlyViewed(_products);
    notifyListeners();
  }

  Future<void> trackAddToCart(ProductModel product) {
    return _repository.trackAddToCart(product.id);
  }

  Future<void> createProduct(ProductModel product) async {
    await _repository.createProduct(product);
    if (_products.every((item) => item.id != product.id)) {
      _products = [product, ..._products];
      notifyListeners();
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    await _repository.updateProduct(product);
    _products = [
      for (final item in _products)
        if (item.id == product.id) product else item,
    ];
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    await _repository.deleteProduct(productId);
    _products = [
      for (final product in _products)
        if (product.id != productId) product,
    ];
    notifyListeners();
  }

  @override
  void dispose() {
    _searchHistoryDebounce?.cancel();
    _productSubscription?.cancel();
    _networkSubscription?.cancel();
    _recommendationEngine.dispose();
    super.dispose();
  }

  void _queueSearchHistoryUpdate(String query) {
    _searchHistoryDebounce?.cancel();
    if (query.length < 2) return;

    _searchHistoryDebounce = Timer(const Duration(milliseconds: 650), () {
      unawaited(_recordSearch(query));
    });
  }

  Future<void> _recordSearch(String query) async {
    _searchHistory = await _repository.recordSearch(query);
    await _refreshRecommendations();
  }

  Future<void> _refreshRecommendations() async {
    final request = ++_recommendationRequest;
    final recommendations = await _recommendationEngine.recommend(
      products: _products,
      searchHistory: _searchHistory,
      limit: 8,
    );
    if (request != _recommendationRequest) return;

    _recommendations = recommendations;
    notifyListeners();
  }
}
