import 'dart:async';
import 'dart:developer' as developer;

import '../models/order_model.dart';

class OrderRepository {
  final List<OrderModel> _orders = [];
  final StreamController<List<OrderModel>> _controller =
      StreamController<List<OrderModel>>.broadcast();

  Stream<List<OrderModel>> watchOrders(String userId) async* {
    yield _ordersForUser(userId);
    yield* _controller.stream.map((_) => _ordersForUser(userId));
  }

  Stream<List<OrderModel>> watchAllOrders() async* {
    yield _sortedOrders();
    yield* _controller.stream.map((_) => _sortedOrders());
  }

  Future<OrderModel> createOrder({required OrderModel order}) async {
    developer.log(
      'Saving local order ${order.orderId} for userId=${order.userId}',
      name: 'OrderRepository',
    );
    final existingIndex = _orders.indexWhere(
      (existing) => existing.orderId == order.orderId,
    );
    if (existingIndex == -1) {
      _orders.insert(0, order);
    } else {
      _orders[existingIndex] = order;
    }
    _emit();
    return order;
  }

  Future<void> updatePaymentStatus({
    required String userId,
    required String orderId,
    required PaymentStatus status,
    String? paymentId,
    String? razorpayOrderId,
    String? paymentSignature,
  }) async {
    final index = _orders.indexWhere(
      (order) => order.orderId == orderId && order.userId == userId,
    );
    if (index == -1) return;

    _orders[index] = _orders[index].copyWith(
      paymentStatus: status,
      paymentId: paymentId,
      razorpayOrderId: razorpayOrderId,
      paymentSignature: paymentSignature,
    );
    developer.log(
      'Updated local payment status for orderId=$orderId',
      name: 'OrderRepository',
    );
    _emit();
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    return _ordersForUser(userId);
  }

  List<OrderModel> _ordersForUser(String userId) {
    if (userId.isEmpty) return const [];
    final orders = _orders
        .where((order) => order.userId == userId)
        .toList(growable: false);
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  List<OrderModel> _sortedOrders() {
    final orders = _orders.toList(growable: false);
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(_sortedOrders());
    }
  }
}
