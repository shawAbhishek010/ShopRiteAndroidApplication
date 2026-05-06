import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/user_model.dart';
import '../services/firebase/auth_service.dart';
import '../services/firebase/firestore_service.dart';

class AuthRepository {
  AuthRepository({AuthService? authService, FirestoreService? firestoreService})
    : _authService =
          authService ?? (Firebase.apps.isNotEmpty ? AuthService() : null),
      _firestoreService =
          firestoreService ??
          (Firebase.apps.isNotEmpty ? FirestoreService() : null);

  final AuthService? _authService;
  final FirestoreService? _firestoreService;

  bool get _firebaseReady => Firebase.apps.isNotEmpty;

  Stream<UserModel?> authState() {
    if (!_firebaseReady) return Stream<UserModel?>.value(null);

    return _authService!.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return userStream(firebaseUser.uid).first;
    });
  }

  Stream<UserModel?> userStream(String userId) {
    if (!_firebaseReady) return Stream<UserModel?>.value(null);

    return _firestoreService!.userDocument(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return UserModel.fromMap(data, snapshot.id);
    });
  }

  Future<UserModel> login(String email, String password) async {
    if (!_firebaseReady) {
      return _demoUser(email);
    }

    final credential = await _authService!.signIn(
      email: email,
      password: password,
    );
    return _ensureUserDocument(
      userId: credential.user!.uid,
      name: credential.user!.displayName ?? 'ShopRite Customer',
      email: credential.user!.email ?? email,
    );
  }

  Future<UserModel> register(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    if (!_firebaseReady) {
      return UserModel(
        userId: role == UserRole.admin ? 'demo-admin' : 'demo-user',
        name: name,
        email: email,
        role: role,
      );
    }

    final credential = await _authService!.signUp(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    return _ensureUserDocument(
      userId: credential.user!.uid,
      name: name,
      email: credential.user!.email ?? email,
      role: role,
    );
  }

  Future<UserModel> _ensureUserDocument({
    required String userId,
    required String name,
    required String email,
    UserRole role = UserRole.user,
  }) async {
    final reference = _firestoreService!.userDocument(userId);
    final snapshot = await reference.get();
    if (snapshot.exists && snapshot.data() != null) {
      return UserModel.fromMap(snapshot.data()!, snapshot.id);
    }

    final user = UserModel(
      userId: userId,
      name: name,
      email: email,
      role: role,
    );
    await reference.set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return user;
  }

  Future<void> logout() async {
    if (_firebaseReady) await _authService!.signOut();
  }

  UserModel _demoUser(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final isAdmin = normalizedEmail == 'admin@shoprite.com';
    return UserModel(
      userId: isAdmin ? 'demo-admin' : 'demo-user',
      name: isAdmin ? 'ShopRite Admin' : 'Demo Shopper',
      email: email,
      role: isAdmin ? UserRole.admin : UserRole.user,
    );
  }

  String authErrorMessage(Object error) {
    return AuthService.messageForFirebaseAuthError(error);
  }
}
