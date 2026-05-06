import '../models/order_model.dart';

class OrderAnalytics {
  const OrderAnalytics(this.orders);

  final List<OrderModel> orders;

  double get totalRevenue {
    return orders
        .where((order) => order.paymentStatus == PaymentStatus.paid)
        .fold<double>(0, (sum, order) => sum + order.totalAmount);
  }

  int get totalItemsSold {
    return orders.fold<int>(
      0,
      (sum, order) =>
          sum +
          order.items.fold<int>(0, (itemSum, item) => itemSum + item.quantity),
    );
  }

  double get averageOrderValue {
    if (orders.isEmpty) return 0;
    return totalRevenue / orders.length;
  }

  Map<DateTime, double> dailyRevenue() {
    final data = <DateTime, double>{};
    for (final order in orders) {
      if (order.paymentStatus != PaymentStatus.paid) continue;
      final day = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );
      data.update(
        day,
        (value) => value + order.totalAmount,
        ifAbsent: () => order.totalAmount,
      );
    }
    return data;
  }

  Map<String, int> productUnitsSold() {
    final data = <String, int>{};
    for (final order in orders) {
      for (final item in order.items) {
        data.update(
          item.name,
          (value) => value + item.quantity,
          ifAbsent: () => item.quantity,
        );
      }
    }
    return data;
  }

  Map<String, double> productRevenue() {
    final data = <String, double>{};
    for (final order in orders) {
      if (order.paymentStatus != PaymentStatus.paid) continue;
      for (final item in order.items) {
        data.update(
          item.name,
          (value) => value + item.total,
          ifAbsent: () => item.total,
        );
      }
    }
    return data;
  }

  Map<String, double> categoryRevenue() {
    final data = <String, double>{};
    for (final order in orders) {
      if (order.paymentStatus != PaymentStatus.paid) continue;
      for (final item in order.items) {
        data.update(
          item.category,
          (value) => value + item.total,
          ifAbsent: () => item.total,
        );
      }
    }
    return data;
  }
}
