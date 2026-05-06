import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';
import '../services/payment_service.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  final service = PaymentService();
  ref.onDispose(service.dispose);
  return service;
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository();
});

final userPaymentsProvider = StreamProvider.family<List<PaymentModel>, String?>(
  (ref, userId) {
    if (userId == null || userId.isEmpty) {
      return Stream<List<PaymentModel>>.value(const []);
    }
    return ref.watch(paymentRepositoryProvider).watchUserPayments(userId);
  },
);
