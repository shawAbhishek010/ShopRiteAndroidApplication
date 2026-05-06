class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.discount,
    required this.rating,
    required this.imageUrl,
    required this.stock,
    this.description = '',
    this.views = 0,
    this.addToCartCount = 0,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final double discount;
  final double rating;
  final String imageUrl;
  final int stock;
  final String description;
  final int views;
  final int addToCartCount;

  double get salePrice => price - (price * discount / 100);
  bool get isInStock => stock > 0;

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: (map['id'] as String?) ?? id,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? '',
      price: (map['price'] as num? ?? 0).toDouble(),
      discount: (map['discount'] as num? ?? 0).toDouble(),
      rating: (map['rating'] as num? ?? 0).toDouble(),
      imageUrl: map['imageUrl'] as String? ?? '',
      stock: (map['stock'] as num? ?? 0).toInt(),
      description: map['description'] as String? ?? '',
      views: (map['views'] as num? ?? 0).toInt(),
      addToCartCount: (map['addToCartCount'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'discount': discount,
      'rating': rating,
      'imageUrl': imageUrl,
      'stock': stock,
      'description': description,
      'views': views,
      'addToCartCount': addToCartCount,
    };
  }
}
