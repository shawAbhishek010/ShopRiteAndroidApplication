import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:provider/provider.dart';

import '../../core/utils/helpers.dart';
import '../../domain/order_analytics.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../state/order_provider.dart';

class OrderScreen extends riverpod.ConsumerWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final auth = context.watch<AuthProvider>();
    final isAdminMode = auth.isAdmin;
    final userId = auth.user?.userId;
    final ordersAsync = ref.watch(
      userOrdersProvider(
        OrderListRequest(userId: userId, isAdmin: isAdminMode),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdminMode ? 'Orders and analytics' : 'My orders'),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('Orders could not be loaded. Check your connection.'),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Text(
                isAdminMode
                    ? 'No orders have been placed yet.'
                    : 'No orders yet. Your first checkout starts here.',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isAdminMode) ...[
                _AdminAnalytics(orders: orders),
                const SizedBox(height: 24),
                Text(
                  'Recent orders',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ] else
                Text(
                  'My orders',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              const SizedBox(height: 10),
              ...orders.map(
                (order) => _OrderTile(
                  order: order,
                  isAdminMode: isAdminMode,
                  userId: userId,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminAnalytics extends StatelessWidget {
  const _AdminAnalytics({required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    final analytics = OrderAnalytics(orders);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              label: 'Revenue',
              value: Helpers.formatCurrency(analytics.totalRevenue),
              icon: Icons.payments_outlined,
            ),
            _MetricCard(
              label: 'Orders',
              value: '${orders.length}',
              icon: Icons.receipt_long_outlined,
            ),
            _MetricCard(
              label: 'Items sold',
              value: '${analytics.totalItemsSold}',
              icon: Icons.inventory_2_outlined,
            ),
            _MetricCard(
              label: 'Avg order',
              value: Helpers.formatCurrency(analytics.averageOrderValue),
              icon: Icons.trending_up,
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final charts = [
              _ChartPanel(
                title: 'Daily revenue',
                child: _DailyRevenueChart(data: analytics.dailyRevenue()),
              ),
              _ChartPanel(
                title: 'Sales by category',
                child: _CategoryRevenuePie(data: analytics.categoryRevenue()),
              ),
              _ChartPanel(
                title: 'Top products sold',
                child: _TopProductsChart(data: analytics.productUnitsSold()),
              ),
              _ChartPanel(
                title: 'Top product revenue',
                child: _ProductRevenueList(data: analytics.productRevenue()),
              ),
            ];

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final chart in charts)
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 12) / 2
                        : constraints.maxWidth,
                    child: chart,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OrderTile extends riverpod.ConsumerWidget {
  const _OrderTile({
    required this.order,
    required this.isAdminMode,
    required this.userId,
  });

  final OrderModel order;
  final bool isAdminMode;
  final String? userId;

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final itemPreview = order.items.take(2).map((item) => item.name).join(', ');
    final actionState = ref.watch(orderProvider);
    final isPaying = actionState.payingOrderId == order.orderId;
    final canPay =
        !isAdminMode &&
        userId != null &&
        order.paymentStatus == PaymentStatus.pending;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.shopping_bag_outlined),
        title: Text('Order #${order.orderId}'),
        subtitle: Text(
          [
            if (itemPreview.isNotEmpty) itemPreview,
            '${order.items.length} products',
            '${_itemCount(order)} items',
            Helpers.capitalize(order.status.name),
            Helpers.capitalize(order.paymentStatus.name),
            if (isAdminMode && order.phoneNumber.isNotEmpty) order.phoneNumber,
          ].join('  |  '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: canPay
            ? FilledButton(
                onPressed: isPaying
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await ref
                            .read(orderProvider.notifier)
                            .payPendingOrder(userId: userId!, order: order);
                        final state = ref.read(orderProvider);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? state.successMessage ??
                                        'Payment successful.'
                                  : state.errorMessage ??
                                        'Payment could not be completed.',
                            ),
                          ),
                        );
                      },
                child: Text(isPaying ? 'Paying...' : 'Pay Now'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Helpers.formatCurrency(order.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      order.paymentStatus == PaymentStatus.paid
                          ? 'Paid'
                          : Helpers.capitalize(order.paymentStatus.name),
                    ),
                  ),
                ],
              ),
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.orderTracking,
          arguments: order,
        ),
      ),
    );
  }

  int _itemCount(OrderModel order) {
    return order.items.fold<int>(0, (sum, item) => sum + item.quantity);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 10),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _DailyRevenueChart extends StatelessWidget {
  const _DailyRevenueChart({required this.data});

  final Map<DateTime, double> data;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final visibleEntries = entries.length > 7
        ? entries.sublist(entries.length - 7)
        : entries;
    final maxRevenue = visibleEntries.fold<double>(
      1,
      (max, entry) => entry.value > max ? entry.value : max,
    );

    return SizedBox(
      height: 230,
      child: BarChart(
        BarChartData(
          maxY: maxRevenue * 1.2,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 44),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= visibleEntries.length) {
                    return const SizedBox.shrink();
                  }
                  final day = visibleEntries[index].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('${day.day}/${day.month}'),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var index = 0; index < visibleEntries.length; index++)
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: visibleEntries[index].value,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRevenuePie extends StatelessWidget {
  const _CategoryRevenuePie({required this.data});

  final Map<String, double> data;

  @override
  Widget build(BuildContext context) {
    final entries = _topEntries(data, 6);
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);
    if (entries.isEmpty || total <= 0) {
      return const SizedBox(
        height: 230,
        child: Center(child: Text('No sales')),
      );
    }

    final colors = _chartColors(context);
    return SizedBox(
      height: 260,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 42,
                sections: [
                  for (var index = 0; index < entries.length; index++)
                    PieChartSectionData(
                      value: entries[index].value,
                      title:
                          '${((entries[index].value / total) * 100).round()}%',
                      radius: 70,
                      color: colors[index % colors.length],
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < entries.length; index++)
                  _LegendRow(
                    color: colors[index % colors.length],
                    label: entries[index].key,
                    value: Helpers.formatCurrency(entries[index].value),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProductsChart extends StatelessWidget {
  const _TopProductsChart({required this.data});

  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    final entries = _topEntries(data, 5);
    if (entries.isEmpty) {
      return const SizedBox(
        height: 230,
        child: Center(child: Text('No sales')),
      );
    }

    final maxUnits = entries.fold<int>(
      1,
      (max, entry) => entry.value > max ? entry.value : max,
    );
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: maxUnits + 1,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: 1,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: 70,
                      child: Text(
                        entries[index].key,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var index = 0; index < entries.length; index++)
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entries[index].value.toDouble(),
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductRevenueList extends StatelessWidget {
  const _ProductRevenueList({required this.data});

  final Map<String, double> data;

  @override
  Widget build(BuildContext context) {
    final entries = _topEntries(data, 6);
    if (entries.isEmpty) {
      return const SizedBox(
        height: 230,
        child: Center(child: Text('No sales')),
      );
    }

    final maxValue = entries.fold<double>(
      1,
      (max, entry) => entry.value > max ? entry.value : max,
    );
    return SizedBox(
      height: 250,
      child: Column(
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      entry.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: math.max(0.05, entry.value / maxValue),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    child: Text(
                      Helpers.formatCurrency(entry.value),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

List<MapEntry<String, T>> _topEntries<T extends num>(
  Map<String, T> data,
  int limit,
) {
  final entries = data.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries.take(limit).toList();
}

List<Color> _chartColors(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return [
    colorScheme.primary,
    colorScheme.secondary,
    colorScheme.tertiary,
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
  ];
}
