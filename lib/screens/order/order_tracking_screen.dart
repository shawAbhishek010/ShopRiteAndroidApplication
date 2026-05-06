import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/utils/helpers.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)?.settings.arguments as OrderModel?;
    final currentIndex = order == null
        ? 0
        : OrderStatus.values.indexOf(order.status);
    return Scaffold(
      appBar: AppBar(title: const Text('Track order')),
      body: order == null
          ? const Center(child: Text('Order not found.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _OrderSummary(order: order),
                const SizedBox(height: 12),
                Text('Products', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...order.items.map((item) => _OrderItemTile(item: item)),
                const SizedBox(height: 12),
                _DeliveryDetails(order: order),
                const SizedBox(height: 12),
                _PaymentDetails(order: order),
                const SizedBox(height: 12),
                Text('Tracking', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                SizedBox(
                  height: 430,
                  child: Stepper(
                    currentStep: currentIndex.clamp(0, 3),
                    physics: const NeverScrollableScrollPhysics(),
                    controlsBuilder: (_, _) => const SizedBox.shrink(),
                    steps: const [
                      Step(
                        title: Text('Placed'),
                        content: Text('Order received.'),
                      ),
                      Step(
                        title: Text('Packed'),
                        content: Text('Items are being packed.'),
                      ),
                      Step(
                        title: Text('Shipped'),
                        content: Text('Courier has picked it up.'),
                      ),
                      Step(
                        title: Text('Delivered'),
                        content: Text('Enjoy your order.'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final itemCount = order.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.orderId}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(Helpers.capitalize(order.status.name)),
                  avatar: const Icon(Icons.local_shipping_outlined, size: 18),
                ),
                Chip(
                  label: Text('$itemCount items'),
                  avatar: const Icon(Icons.inventory_2_outlined, size: 18),
                ),
                Chip(
                  label: Text(Helpers.formatCurrency(order.totalAmount)),
                  avatar: const Icon(Icons.payments_outlined, size: 18),
                ),
                Chip(
                  label: Text(Helpers.capitalize(order.paymentStatus.name)),
                  avatar: Icon(
                    order.paymentStatus == PaymentStatus.paid
                        ? Icons.verified_outlined
                        : Icons.schedule_outlined,
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 54,
            height: 54,
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 140,
              errorWidget: (_, _, _) =>
                  const Icon(Icons.image_not_supported_outlined),
            ),
          ),
        ),
        title: Text(item.name),
        subtitle: Text('${item.category}  |  Qty: ${item.quantity}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Helpers.formatCurrency(item.total)),
            Text(
              Helpers.formatCurrency(item.price),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryDetails extends StatelessWidget {
  const _DeliveryDetails({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Phone number'),
            subtitle: Text(order.phoneNumber),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Delivery address'),
            subtitle: Text(order.deliveryAddress),
          ),
        ],
      ),
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  const _PaymentDetails({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Payment ID'),
            subtitle: Text(
              (order.paymentId ?? '').isEmpty
                  ? 'Not available'
                  : order.paymentId!,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: const Text('Payment status'),
            subtitle: Text(Helpers.capitalize(order.paymentStatus.name)),
          ),
          if (order.razorpayOrderId.isNotEmpty) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: const Text('Razorpay order ID'),
              subtitle: Text(order.razorpayOrderId),
            ),
          ],
        ],
      ),
    );
  }
}
