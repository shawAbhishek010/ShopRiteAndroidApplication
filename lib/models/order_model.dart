import 'cart_item_model.dart';

enum OrderStatus { placed, packed, shipped, delivered, cancelled }

enum PaymentStatus { paid, pending, failed }

enum PaymentMode { payNow, payLater }

class OrderModel {
  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.paymentStatus,
    this.paymentId,
    this.razorpayOrderId = '',
    this.paymentSignature = '',
  });

  String get id => orderId;

  final String orderId;
  final String userId;
  final List<CartItemModel> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final String phoneNumber;
  final String deliveryAddress;
  final PaymentStatus paymentStatus;
  final String? paymentId;
  final String razorpayOrderId;
  final String paymentSignature;

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: map['orderId'] as String? ?? id,
      userId: map['userId'] as String? ?? '',
      items: ((map['products'] as List?) ?? (map['items'] as List?) ?? const [])
          .map((item) => CartItemModel.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      totalAmount: (map['totalAmount'] as num? ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (status) =>
            status.name == ((map['orderStatus'] as String?) ?? map['status']),
        orElse: () => OrderStatus.placed,
      ),
      createdAt: _dateFrom(map['createdAt']),
      phoneNumber: map['phoneNumber'] as String? ?? '',
      deliveryAddress: map['deliveryAddress'] as String? ?? '',
      paymentStatus: PaymentStatus.values.firstWhere(
        (status) => status.name == map['paymentStatus'],
        orElse: () => (map['paymentId'] as String? ?? '').isEmpty
            ? PaymentStatus.pending
            : PaymentStatus.paid,
      ),
      paymentId: map['paymentId'] as String?,
      razorpayOrderId: map['razorpayOrderId'] as String? ?? '',
      paymentSignature: map['paymentSignature'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': orderId,
      'orderId': orderId,
      'userId': userId,
      'products': items.map((item) => item.toMap()).toList(),
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderStatus': status.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'phoneNumber': phoneNumber,
      'deliveryAddress': deliveryAddress,
      'paymentStatus': paymentStatus.name,
      'paymentId': paymentId,
      'razorpayOrderId': razorpayOrderId,
      'paymentSignature': paymentSignature,
    };
  }

  OrderModel copyWith({
    String? paymentId,
    PaymentStatus? paymentStatus,
    String? razorpayOrderId,
    String? paymentSignature,
  }) {
    return OrderModel(
      orderId: orderId,
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      status: status,
      createdAt: createdAt,
      phoneNumber: phoneNumber,
      deliveryAddress: deliveryAddress,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      paymentSignature: paymentSignature ?? this.paymentSignature,
    );
  }

  static DateTime _dateFrom(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
