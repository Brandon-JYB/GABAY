import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// Real backend for AuthRepository, using Supabase Auth.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final sb.SupabaseClient _client;

  @override
  AuthUser? get currentUser => _toAuthUser(_client.auth.currentUser);

  AuthUser? _toAuthUser(sb.User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.id,
      fullName: (user.userMetadata?['full_name'] as String?) ?? '',
      email: user.email ?? '',
    );
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth
          .signInWithPassword(email: email.trim(), password: password);
      final user = _toAuthUser(response.user);
      if (user == null) {
        throw const AuthException('Incorrect email or password.');
      }
      return user;
    } on AuthException {
      rethrow;
    } on sb.AuthException catch (e) {
      throw AuthException(_friendly(e.message));
    } catch (_) {
      throw const AuthException(
          'Could not reach the server. Check your connection and try again.');
    }
  }

  @override
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        // Copied into the profiles table by the database trigger.
        data: {'full_name': fullName.trim()},
      );
      final user = _toAuthUser(response.user);
      if (user == null) {
        throw const AuthException('Could not create the account.');
      }
      if (response.session == null) {
        // "Confirm email" is turned on in Supabase.
        throw const AuthException(
            'Account created. Please check your email to confirm it, then log in.');
      }
      return user;
    } on AuthException {
      rethrow;
    } on sb.AuthException catch (e) {
      throw AuthException(_friendly(e.message));
    } catch (_) {
      throw const AuthException(
          'Could not reach the server. Check your connection and try again.');
    }
  }

  @override
  Future<void> logout() => _client.auth.signOut();

  String _friendly(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login')) return 'Incorrect email or password.';
    if (m.contains('already registered')) {
      return 'An account with this email already exists.';
    }
    if (m.contains('not confirmed')) {
      return 'Please confirm your email first. Check your inbox.';
    }
    return message;
  }
}