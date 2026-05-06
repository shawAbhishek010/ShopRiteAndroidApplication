enum UserRole {
  user,
  admin;

  static UserRole fromValue(String? value) {
    return switch (value) {
      'admin' => UserRole.admin,
      _ => UserRole.user,
    };
  }
}

class UserModel {
  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.role = UserRole.user,
    this.wishlist = const [],
    this.cart = const [],
  });

  final String userId;
  final String name;
  final String email;
  final UserRole role;
  final List<String> wishlist;
  final List<Map<String, dynamic>> cart;

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      userId: map['userId'] as String? ?? id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: UserRole.fromValue(map['role'] as String?),
      wishlist: List<String>.from(map['wishlist'] as List? ?? const []),
      cart: List<Map<String, dynamic>>.from(map['cart'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role.name,
      'wishlist': wishlist,
      'cart': cart,
    };
  }
}
