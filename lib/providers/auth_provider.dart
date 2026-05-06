import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum ViewState { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository() {
    _subscription = _repository.authState().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  StreamSubscription<UserModel?>? _subscription;

  UserModel? _user;
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  UserModel? get user => _user;
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<bool> login(
    String email,
    String password, {
    required UserRole role,
  }) async {
    final success = await _runAuth(() => _repository.login(email, password));
    if (!success) return false;

    if (_user?.role != role) {
      await logout();
      _state = ViewState.error;
      _errorMessage = role == UserRole.admin
          ? 'This account is not an admin account.'
          : 'Please login from the admin tab for this account.';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<bool> register(
    String name,
    String email,
    String password, {
    required UserRole role,
  }) async {
    return _runAuth(() => _repository.register(name, email, password, role));
  }

  Future<bool> _runAuth(Future<UserModel> Function() task) async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await task();
      _state = ViewState.success;
      notifyListeners();
      return true;
    } catch (error) {
      _state = ViewState.error;
      _errorMessage = _repository.authErrorMessage(error);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
