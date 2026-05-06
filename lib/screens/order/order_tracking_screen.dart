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
    return Scaffold(
      appBar: AppBar(title: const Text('Track order')),
      body: order == null
          ? const Center(child: Text('Order not found.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TrackingProgress(order: order),
                const SizedBox(height: 12),
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
                _TrackingDetails(order: order),
              ],
            ),
    );
  }
}

class _TrackingProgress extends StatelessWidget {
  const _TrackingProgress({required this.order});

  final OrderModel order;

  static const _stages = [
    _TrackingStage(
      label: 'Order\nPlaced',
      title: 'Placed',
      description: 'Order received.',
      icon: Icons.shopping_bag_outlined,
    ),
    _TrackingStage(
      label: 'Packed',
      title: 'Packed',
      description: 'Items are being packed.',
      icon: Icons.inventory_2_outlined,
    ),
    _TrackingStage(
      label: 'In\nTransit',
      title: 'Shipped',
      description: 'Courier has picked it up.',
      icon: Icons.local_shipping_outlined,
    ),
    _TrackingStage(
      label: 'Delivered',
      title: 'Delivered',
      description: 'Enjoy your order.',
      icon: Icons.check_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(order.status);
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.outline.withValues(alpha: 0.38);
    final trackColor = colorScheme.primary.withValues(alpha: 0.22);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
        child: Column(
          children: [
            Text(
              'Track Your Order',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 112,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const circleSize = 56.0;
                  return Stack(
                    children: [
                      Positioned(
                        left: circleSize / 2,
                        right: circleSize / 2,
                        top: 27,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: inactiveColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      Positioned(
                        left: circleSize / 2,
                        top: 27,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 6,
                          width:
                              (constraints.maxWidth - circleSize) *
                              (currentIndex / (_stages.length - 1)),
                          decoration: BoxDecoration(
                            color: activeColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var index = 0; index < _stages.length; index++)
                            Expanded(
                              child: _TrackingNode(
                                stage: _stages[index],
                                isActive: index <= currentIndex,
                                circleSize: circleSize,
                                activeColor: activeColor,
                                inactiveColor: inactiveColor,
                                trackColor: trackColor,
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int _currentIndex(OrderStatus status) {
    return switch (status) {
      OrderStatus.placed => 0,
      OrderStatus.packed => 1,
      OrderStatus.shipped => 2,
      OrderStatus.delivered => 3,
      OrderStatus.cancelled => 0,
    };
  }
}

class _TrackingNode extends StatelessWidget {
  const _TrackingNode({
    required this.stage,
    required this.isActive,
    required this.circleSize,
    required this.activeColor,
    required this.inactiveColor,
    required this.trackColor,
  });

  final _TrackingStage stage;
  final bool isActive;
  final double circleSize;
  final Color activeColor;
  final Color inactiveColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? trackColor
                : Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: isActive ? activeColor : inactiveColor,
              width: isActive ? 2 : 1.5,
            ),
          ),
          child: Icon(
            stage.icon,
            color: isActive ? activeColor : inactiveColor,
            size: 29,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          stage.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TrackingDetails extends StatelessWidget {
  const _TrackingDetails({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final currentIndex = _TrackingProgress._currentIndex(order.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            for (
              var index = 0;
              index < _TrackingProgress._stages.length;
              index++
            )
              _TrackingDetailRow(
                index: index,
                stage: _TrackingProgress._stages[index],
                isActive: index <= currentIndex,
                isLast: index == _TrackingProgress._stages.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _TrackingDetailRow extends StatelessWidget {
  const _TrackingDetailRow({
    required this.index,
    required this.stage,
    required this.isActive,
    required this.isLast,
  });

  final int index;
  final _TrackingStage stage;
  final bool isActive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.outline.withValues(alpha: 0.45);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 58,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? activeColor.withValues(alpha: 0.14)
                        : colorScheme.surface,
                    border: Border.all(
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isActive ? activeColor : inactiveColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 14, bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stage.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStage {
  const _TrackingStage({
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String label;
  final String title;
  final String description;
  final IconData icon;
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
