import 'product_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.quantity = 1,
  });

  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final int quantity;

  double get total => price * quantity;

  factory CartItemModel.fromProduct(ProductModel product) {
    return CartItemModel(
      productId: product.id,
      name: product.name,
      price: product.salePrice,
      imageUrl: product.imageUrl,
      category: product.category,
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num? ?? 0).toDouble(),
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? '',
      quantity: (map['quantity'] as num? ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      productId: productId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      category: category,
      quantity: quantity ?? this.quantity,
    );
  }
}
