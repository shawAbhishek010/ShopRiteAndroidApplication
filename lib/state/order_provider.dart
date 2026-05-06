import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_model.dart';
import '../repositories/order_repository.dart';
import '../services/razorpay_service.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final razorpayServiceProvider = Provider<RazorpayService>((ref) {
  final service = RazorpayService();
  ref.onDispose(service.dispose);
  return service;
});

final orderProvider = NotifierProvider<OrderController, OrderActionState>(
  OrderController.new,
);

final userOrdersProvider =
    StreamProvider.family<List<OrderModel>, OrderListRequest>((ref, request) {
      final repository = ref.watch(orderRepositoryProvider);
      if (request.userId == null || request.userId!.isEmpty) {
        return const Stream<List<OrderModel>>.empty();
      }
      return request.isAdmin
          ? repository.watchAllOrders()
          : repository.watchOrders(request.userId!);
    });

class OrderListRequest {
  const OrderListRequest({required this.userId, required this.isAdmin});

  final String? userId;
  final bool isAdmin;

  @override
  bool operator ==(Object other) {
    return other is OrderListRequest &&
        other.userId == userId &&
        other.isAdmin == isAdmin;
  }

  @override
  int get hashCode => Object.hash(userId, isAdmin);
}

class OrderActionState {
  const OrderActionState({
    this.payingOrderId,
    this.errorMessage,
    this.successMessage,
  });

  final String? payingOrderId;
  final String? errorMessage;
  final String? successMessage;

  bool get isPaying => payingOrderId != null;

  OrderActionState copyWith({
    String? payingOrderId,
    String? errorMessage,
    String? successMessage,
    bool clearPayingOrder = false,
    bool clearMessages = false,
  }) {
    return OrderActionState(
      payingOrderId: clearPayingOrder
          ? null
          : payingOrderId ?? this.payingOrderId,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }
}

class OrderController extends Notifier<OrderActionState> {
  @override
  OrderActionState build() {
    return const OrderActionState();
  }

  Future<bool> payPendingOrder({
    required String userId,
    required OrderModel order,
  }) async {
    if (state.isPaying) return false;
    if (order.paymentStatus != PaymentStatus.pending) return false;

    state = OrderActionState(payingOrderId: order.orderId);

    try {
      final payment = await _openPayment(
        amount: order.totalAmount,
        email: '',
        phoneNumber: order.phoneNumber,
        receipt: 'shoprite_retry_${order.orderId}',
      );
      await ref
          .read(orderRepositoryProvider)
          .updatePaymentStatus(
            userId: userId,
            orderId: order.orderId,
            status: PaymentStatus.paid,
            paymentId: payment.paymentId,
            razorpayOrderId: payment.orderId,
            paymentSignature: payment.signature,
          );
      state = const OrderActionState(
        successMessage: 'Payment successful. Order updated.',
      );
      return true;
    } catch (error) {
      state = OrderActionState(errorMessage: error.toString());
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }

  Future<RazorpayPaymentResult> _openPayment({
    required double amount,
    required String email,
    required String phoneNumber,
    required String receipt,
  }) {
    return ref
        .read(razorpayServiceProvider)
        .openCheckout(
          amount: (amount * 100).round(),
          email: email,
          phoneNumber: phoneNumber,
          receipt: receipt,
        );
  }
}
