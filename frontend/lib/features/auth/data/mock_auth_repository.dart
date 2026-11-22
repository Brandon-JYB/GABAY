import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

class _Account {
  _Account(this.user, this.password);
  final AuthUser user;
  final String password;
}

/// In-memory stand-in until the backend exists. For development only:
/// accounts vanish on restart and passwords are never stored like this for real.
class MockAuthRepository implements AuthRepository {
  final Map<String, _Account> _accounts = {};
  AuthUser? _current;

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException('An account with this email already exists.');
    }
    final user = AuthUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fullName: fullName.trim(),
      email: key,
    );
    _accounts[key] = _Account(user, password);
    return _current = user;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException('Incorrect email or password.');
    }
    return _current = account.user;
  }

  @override
  Future<void> logout() async {
    _current = null;
  }
}