import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import 'order_provider.dart';
import 'payment_provider.dart';

final checkoutProvider = NotifierProvider<CheckoutController, CheckoutState>(
  CheckoutController.new,
);

class CheckoutState {
  const CheckoutState({
    this.paymentMode = PaymentMode.payNow,
    this.isLoading = false,
    this.errorMessage,
    this.lastOrder,
  });

  final PaymentMode paymentMode;
  final bool isLoading;
  final String? errorMessage;
  final OrderModel? lastOrder;

  CheckoutState copyWith({
    PaymentMode? paymentMode,
    bool? isLoading,
    String? errorMessage,
    OrderModel? lastOrder,
    bool clearError = false,
    bool clearLastOrder = false,
  }) {
    return CheckoutState(
      paymentMode: paymentMode ?? this.paymentMode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage,
      lastOrder: clearLastOrder ? null : lastOrder ?? this.lastOrder,
    );
  }
}

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    return const CheckoutState();
  }

  void selectPaymentMode(PaymentMode mode) {
    state = state.copyWith(paymentMode: mode, clearError: true);
  }

  Future<OrderModel?> createOrder({
    required String userId,
    required String email,
    required List<CartItemModel> items,
    required double amount,
    required String phoneNumber,
    required String deliveryAddress,
  }) async {
    if (state.isLoading) return null;
    if (userId.isEmpty || items.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Add products before checkout.',
        clearLastOrder: true,
      );
      return null;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearLastOrder: true,
    );

    try {
      final orderId = DateTime.now().microsecondsSinceEpoch.toString();
      PaymentResult? payment;
      var paymentStatus = PaymentStatus.pending;

      if (state.paymentMode == PaymentMode.payNow) {
        payment = await _openPayment(
          amount: amount,
          userId: userId,
          orderId: orderId,
          email: email,
          phoneNumber: phoneNumber,
        );
        paymentStatus = PaymentStatus.paid;
      }

      final order = OrderModel(
        orderId: orderId,
        userId: userId,
        items: List.unmodifiable(items),
        totalAmount: amount,
        status: OrderStatus.placed,
        createdAt: DateTime.now(),
        phoneNumber: phoneNumber,
        deliveryAddress: deliveryAddress,
        paymentStatus: paymentStatus,
        paymentId: payment?.paymentId,
        razorpayOrderId: payment?.razorpayOrderId ?? '',
        paymentSignature: payment?.signature ?? '',
      );

      final createdOrder = await ref
          .read(orderRepositoryProvider)
          .createOrder(order: order)
          .timeout(const Duration(seconds: 12));
      if (payment != null) {
        await ref
            .read(paymentRepositoryProvider)
            .savePayment(
              PaymentModel(
                paymentId: payment.paymentId,
                orderId: createdOrder.orderId,
                amount: createdOrder.totalAmount,
                userId: createdOrder.userId,
                createdAt: DateTime.now(),
                status: createdOrder.paymentStatus.name,
                razorpayOrderId: payment.razorpayOrderId,
                paymentSignature: payment.signature,
              ),
            )
            .timeout(const Duration(seconds: 12));
      }
      state = state.copyWith(isLoading: false, lastOrder: createdOrder);
      return createdOrder;
    } on TimeoutException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Checkout is taking too long. Please try again.',
      );
      return null;
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
      return null;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true);
  }

  Future<PaymentResult> _openPayment({
    required double amount,
    required String userId,
    required String orderId,
    required String email,
    required String phoneNumber,
  }) {
    return ref
        .read(paymentServiceProvider)
        .openCheckout(
          amount: (amount * 100).round(),
          userId: userId,
          orderId: orderId,
          email: email,
          phoneNumber: phoneNumber,
        );
  }
}
