import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  DocumentReference<Map<String, dynamic>> userDocument(String userId) {
    return collection('users').doc(userId);
  }

  CollectionReference<Map<String, dynamic>> userOrdersCollection(
    String userId,
  ) {
    return userDocument(userId).collection('orders');
  }

  Query<Map<String, dynamic>> productsQuery() {
    return collection('products').orderBy('rating', descending: true);
  }

  Query<Map<String, dynamic>> userOrdersQuery(String userId) {
    return userOrdersCollection(userId).orderBy('createdAt', descending: true);
  }

  Query<Map<String, dynamic>> ordersQuery() {
    return _firestore
        .collectionGroup('orders')
        .orderBy('createdAt', descending: true);
  }
}
