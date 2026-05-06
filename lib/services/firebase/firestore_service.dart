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

  Query<Map<String, dynamic>> productsQuery() {
    return collection('products').orderBy('rating', descending: true);
  }
}
