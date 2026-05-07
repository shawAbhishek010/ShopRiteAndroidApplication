import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/utils/helpers.dart';
import '../../models/payment_model.dart';
import '../../providers/auth_provider.dart';
import '../../state/payment_provider.dart';

class PaymentHistoryScreen extends riverpod.ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final auth = context.watch<AuthProvider>();
    final paymentsAsync = ref.watch(userPaymentsProvider(auth.user?.userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Payment history')),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Payment history could not be loaded.')),
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(child: Text('No Payment History'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _PaymentTile(payment: payments[index]);
            },
          );
        },
      ),
    );
  }
}
//done
class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});

  final PaymentModel payment;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy, hh:mm a').format(payment.createdAt);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.payments_outlined),
        title: Text(Helpers.formatCurrency(payment.amount)),
        subtitle: Text(
          [
            'Payment ID: ${payment.paymentId}',
            'Order ID: ${payment.orderId}',
            'Date: $date',
          ].join('\n'),
        ),
        isThreeLine: true,
        trailing: Chip(
          visualDensity: VisualDensity.compact,
          label: Text(Helpers.capitalize(payment.status)),
        ),
      ),
    );
  }
}
