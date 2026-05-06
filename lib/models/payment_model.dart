class PaymentModel {
  const PaymentModel({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.userId,
    required this.createdAt,
    required this.status,
    this.razorpayOrderId = '',
    this.paymentSignature = '',
  });

  final String paymentId;
  final String orderId;
  final double amount;
  final String userId;
  final DateTime createdAt;
  final String status;
  final String razorpayOrderId;
  final String paymentSignature;

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      paymentId: map['paymentId'] as String? ?? id,
      orderId: map['orderId'] as String? ?? '',
      amount: (map['amount'] as num? ?? 0).toDouble(),
      userId: map['userId'] as String? ?? '',
      createdAt: _dateFrom(map['createdAt'] ?? map['dateTime']),
      status: map['status'] as String? ?? 'paid',
      razorpayOrderId: map['razorpayOrderId'] as String? ?? '',
      paymentSignature: map['paymentSignature'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'amount': amount,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'razorpayOrderId': razorpayOrderId,
      'paymentSignature': paymentSignature,
    };
  }

  static DateTime _dateFrom(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
