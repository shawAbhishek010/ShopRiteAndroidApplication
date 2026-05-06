import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/order_model.dart';
import '../services/firebase/firestore_service.dart';

class OrderRepository {
  OrderRepository({FirestoreService? firestoreService})
    : _firestoreService =
          firestoreService ??
          (Firebase.apps.isNotEmpty ? FirestoreService() : null);

  final FirestoreService? _firestoreService;
  final List<OrderModel> _demoOrders = [];

  bool get _firebaseReady => Firebase.apps.isNotEmpty;

  Stream<List<OrderModel>> watchOrders(String userId) {
    if (!_firebaseReady) {
      return Stream<List<OrderModel>>.value(
        _demoOrders
            .where((order) => order.userId == userId)
            .toList(growable: false),
      );
    }

    return _firestoreService!.userOrdersQuery(userId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<OrderModel>> watchAllOrders() {
    if (!_firebaseReady) return Stream<List<OrderModel>>.value(_demoOrders);

    return _firestoreService!.ordersQuery().snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<OrderModel> createOrder({required OrderModel order}) async {
    if (!_firebaseReady) {
      _saveDemoOrder(order);
      return order;
    }

    try {
      await _firestoreService!
          .userOrdersCollection(order.userId)
          .doc(order.orderId)
          .set(order.toMap());
    } catch (_) {
      _saveDemoOrder(order);
    }

    return order;
  }

  Future<void> updatePaymentStatus({
    required String userId,
    required String orderId,
    required PaymentStatus status,
    String? paymentId,
    String? razorpayOrderId,
    String? paymentSignature,
  }) async {
    final index = _demoOrders.indexWhere((order) => order.orderId == orderId);
    if (index != -1) {
      _demoOrders[index] = _demoOrders[index].copyWith(
        paymentStatus: status,
        paymentId: paymentId,
        razorpayOrderId: razorpayOrderId,
        paymentSignature: paymentSignature,
      );
    }

    if (!_firebaseReady) return;

    await _firestoreService!.userOrdersCollection(userId).doc(orderId).set({
      'paymentStatus': status.name,
      'paymentId': paymentId,
      'razorpayOrderId': razorpayOrderId,
      'paymentSignature': paymentSignature,
    }, SetOptions(merge: true));
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    if (!_firebaseReady) {
      return _demoOrders
          .where((order) => order.userId == userId)
          .toList(growable: false);
    }

    try {
      final snapshot = await _firestoreService!.userOrdersQuery(userId).get();
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (_) {
      return _demoOrders
          .where((order) => order.userId == userId)
          .toList(growable: false);
    }
  }

  void _saveDemoOrder(OrderModel order) {
    final existingIndex = _demoOrders.indexWhere(
      (existing) => existing.orderId == order.orderId,
    );
    if (existingIndex == -1) {
      _demoOrders.insert(0, order);
    } else {
      _demoOrders[existingIndex] = order;
    }
  }
}
