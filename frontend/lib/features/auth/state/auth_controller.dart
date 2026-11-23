import 'package:flutter/foundation.dart';

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthUser? get currentUser => _repository.currentUser;

  Future<bool> login({required String email, required String password}) {
    return _run(() => _repository.login(email: email, password: password));
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _run(() => _repository.register(
          fullName: fullName,
          email: email,
          password: password,
        ));
  }

  Future<void> logout() async {
    await _repository.logout();
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> _run(Future<AuthUser> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
