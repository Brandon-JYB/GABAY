import 'auth_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// The only thing the rest of the app knows about authentication.
/// Implement this against whichever backend you choose.
abstract class AuthRepository {
  AuthUser? get currentUser;

  Future<AuthUser> login({required String email, required String password});

  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> logout();
}
