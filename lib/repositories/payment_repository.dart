import 'dart:async';
import 'dart:developer' as developer;

import '../models/payment_model.dart';

class PaymentRepository {
  final List<PaymentModel> _payments = [];
  final StreamController<List<PaymentModel>> _controller =
      StreamController<List<PaymentModel>>.broadcast();

  Stream<List<PaymentModel>> watchUserPayments(String userId) async* {
    yield _paymentsForUser(userId);
    yield* _controller.stream.map((_) => _paymentsForUser(userId));
  }

  Future<void> savePayment(PaymentModel payment) async {
    developer.log(
      'Saving local payment ${payment.paymentId} for orderId=${payment.orderId}',
      name: 'PaymentRepository',
    );
    final existingIndex = _payments.indexWhere(
      (existing) => existing.paymentId == payment.paymentId,
    );
    if (existingIndex == -1) {
      _payments.insert(0, payment);
    } else {
      _payments[existingIndex] = payment;
    }
    _emit();
  }

  List<PaymentModel> _paymentsForUser(String userId) {
    if (userId.isEmpty) return const [];
    final payments = _payments
        .where((payment) => payment.userId == userId)
        .toList(growable: false);
    payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return payments;
  }

  List<PaymentModel> _sortedPayments() {
    final payments = _payments.toList(growable: false);
    payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return payments;
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(_sortedPayments());
    }
  }
}
