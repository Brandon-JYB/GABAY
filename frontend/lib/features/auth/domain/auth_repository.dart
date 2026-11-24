import 'auth_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  AuthUser? get currentUser;

  Future<AuthUser> register({
    required String fullName,
    required DateTime birthDate,
    required String genderStatus,
    required String address,
    required String email,
    required String password,
  });

  Future<AuthUser> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}