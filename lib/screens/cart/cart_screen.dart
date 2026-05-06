import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:provider/provider.dart';

import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../routes/app_routes.dart';
import '../../state/checkout_provider.dart';
import '../../models/order_model.dart';

class CartScreen extends riverpod.ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  riverpod.ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends riverpod.ConsumerState<CartScreen> {
  final _detailsFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _checkout({
    required AuthProvider auth,
    required CartProvider cart,
  }) async {
    final details = await _askDeliveryDetails();
    if (details == null || !mounted) return;

    final cartProvider = context.read<CartProvider>();
    final navigator = Navigator.of(context);
    final order = await ref
        .read(checkoutProvider.notifier)
        .createOrder(
          userId: auth.user?.userId ?? '',
          email: auth.user?.email ?? '',
          items: cart.items,
          amount: cart.total,
          phoneNumber: details.phoneNumber,
          deliveryAddress: details.deliveryAddress,
        );
    if (!mounted) return;
    if (order == null) {
      final error = ref.read(checkoutProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }

    try {
      await cartProvider.clear();
    } catch (_) {
      // The order is already created; cart sync can recover on the next update.
    }
    if (!mounted) return;
    await _showOrderSuccess(order);
    if (!mounted) return;
    navigator.pushReplacementNamed(AppRoutes.orderTracking, arguments: order);
  }

  Future<_DeliveryDetails?> _askDeliveryDetails() {
    return showDialog<_DeliveryDetails>(
      context: context,
      builder: (context) => riverpod.Consumer(
        builder: (context, ref, _) {
          final paymentMode = ref.watch(
            checkoutProvider.select((state) => state.paymentMode),
          );
          return AlertDialog(
            title: const Text('Delivery details'),
            content: Form(
              key: _detailsFormKey,
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Delivery address',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 10) {
                          return 'Enter a complete address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    SegmentedButton<PaymentMode>(
                      segments: const [
                        ButtonSegment(
                          value: PaymentMode.payNow,
                          icon: Icon(Icons.payment),
                          label: Text('Pay Now'),
                        ),
                        ButtonSegment(
                          value: PaymentMode.payLater,
                          icon: Icon(Icons.schedule_outlined),
                          label: Text('Pay Later'),
                        ),
                      ],
                      selected: {paymentMode},
                      onSelectionChanged: (selection) {
                        ref
                            .read(checkoutProvider.notifier)
                            .selectPaymentMode(selection.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                icon: Icon(
                  paymentMode == PaymentMode.payNow
                      ? Icons.payment
                      : Icons.receipt_long_outlined,
                ),
                label: Text(
                  paymentMode == PaymentMode.payNow ? 'Pay now' : 'Place order',
                ),
                onPressed: () {
                  if (!_detailsFormKey.currentState!.validate()) return;
                  Navigator.pop(
                    context,
                    _DeliveryDetails(
                      phoneNumber: _phoneController.text.trim(),
                      deliveryAddress: _addressController.text.trim(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showOrderSuccess(OrderModel order) {
    final isPaid = order.paymentStatus == PaymentStatus.paid;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 46),
            ),
            const SizedBox(height: 18),
            Text(
              isPaid ? 'Payment successful' : 'Order placed',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isPaid
                  ? 'Your order has been placed.'
                  : 'Payment is pending. You can pay from order history.',
              textAlign: TextAlign.center,
            ),
            if ((order.paymentId ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Payment ID: ${order.paymentId}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Track order'),
          ),
        ],
      ),
    );
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[0-9+\-\s]{10,15}$').hasMatch(phone)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final checkout = ref.watch(checkoutProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty. Add something good.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...cart.items.map(
                  (item) => Dismissible(
                    key: ValueKey(item.productId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Theme.of(context).colorScheme.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => cart.updateQuantity(item.productId, 0),
                    child: Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(Helpers.formatCurrency(item.price)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => cart.updateQuantity(
                                item.productId,
                                item.quantity - 1,
                              ),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              onPressed: () => cart.updateQuantity(
                                item.productId,
                                item.quantity + 1,
                              ),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _PriceRow(label: 'Subtotal', value: cart.subtotal),
                _PriceRow(label: 'Discount', value: -cart.discount),
                _PriceRow(label: 'Delivery', value: cart.deliveryFee),
                const Divider(),
                _PriceRow(label: 'Total', value: cart.total, isTotal: true),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: checkout.isLoading
                      ? null
                      : () => _checkout(auth: auth, cart: cart),
                  icon: const Icon(Icons.payment),
                  label: Text(
                    checkout.isLoading ? 'Processing...' : 'Place order',
                  ),
                ),
                if (checkout.errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    checkout.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _DeliveryDetails {
  const _DeliveryDetails({
    required this.phoneNumber,
    required this.deliveryAddress,
  });

  final String phoneNumber;
  final String deliveryAddress;
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal ? Theme.of(context).textTheme.titleLarge : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(Helpers.formatCurrency(value), style: style),
        ],
      ),
    );
  }
}
