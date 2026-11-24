import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// Real backend for AuthRepository, using Supabase Auth.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final sb.SupabaseClient _client;

  /// Synchronous, so it is built from the signup metadata stored in the session.
  @override
  AuthUser? get currentUser => _fromMetadata(_client.auth.currentUser);

  AuthUser? _fromMetadata(sb.User? user) {
    if (user == null) return null;
    final m = user.userMetadata ?? {};
    final birthday = DateTime.tryParse('${m['birthday'] ?? ''}');
    if (birthday == null) return null;
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      fullName: (m['full_name'] as String?) ?? '',
      birthday: birthday,
      gender: (m['gender'] as String?) ?? '',
      barangay: (m['barangay'] as String?) ?? '',
      sitio: m['sitio'] as String?,
    );
  }

  /// Loads the full row from public.users (includes is_pwd, civil_status, etc.)
  Future<AuthUser> _loadProfile(String userId) async {
    final row =
    await _client.from('users').select().eq('id', userId).single();
    return _fromRow(row);
  }

  AuthUser _fromRow(Map<String, dynamic> row) {
    return AuthUser(
      id: row['id'] as String,
      email: row['email'] as String,
      fullName: row['full_name'] as String,
      birthday: DateTime.parse(row['birthday'] as String),
      gender: row['gender'] as String,
      barangay: row['barangay'] as String,
      sitio: row['sitio'] as String?,
      civilStatus: row['civil_status'] as String?,
      isPhilhealthMember: (row['is_philhealth_member'] as bool?) ?? false,
      isPwd: (row['is_pwd'] as bool?) ?? false,
    );
  }

  /// Splits "[street, ]Brgy. X, Batangas City" into sitio and barangay,
  /// so the register screen does not need to change.
  ({String? sitio, String barangay}) _splitAddress(String address) {
    final parts = address.split(',').map((p) => p.trim()).toList();
    final i = parts.indexWhere((p) => p.startsWith('Brgy.'));
    if (i == -1) return (sitio: null, barangay: address.trim());
    final barangay = parts[i].replaceFirst('Brgy.', '').trim();
    final sitio = i > 0 ? parts.sublist(0, i).join(', ') : null;
    return (sitio: sitio, barangay: barangay);
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth
          .signInWithPassword(email: email.trim(), password: password);
      final authUser = response.user;
      if (authUser == null) {
        throw const AuthException('Incorrect email or password.');
      }
      return await _loadProfile(authUser.id);
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
    required DateTime birthDate,
    required String genderStatus,
    required String address,
    required String email,
    required String password,
  }) async {
    try {
      final loc = _splitAddress(address);
      final birthday = birthDate.toIso8601String().substring(0, 10); // YYYY-MM-DD

      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        // Copied into public.users by the database trigger.
        data: {
          'full_name': fullName.trim(),
          'birthday': birthday,
          'gender': genderStatus,
          'sitio': loc.sitio,
          'barangay': loc.barangay,
        },
      );
      final authUser = response.user;
      if (authUser == null) {
        throw const AuthException('Could not create the account.');
      }
      if (response.session == null) {
        // "Confirm email" is turned on in Supabase.
        throw const AuthException(
            'Account created. Please check your email to confirm it, then log in.');
      }
      return await _loadProfile(authUser.id);
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