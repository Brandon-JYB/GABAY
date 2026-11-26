import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import 'package:flutter/foundation.dart';

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
      gender: (m['gender_status'] as String?) ?? '',
      barangay: (m['barangay'] as String?) ?? '',
      sitio: m['sitio'] as String?,
    );
  }

  /// Loads the full row from public.users (includes is_pwd, civil_status, etc.)
  Future<AuthUser> _loadProfile(sb.User authUser) async {
    try {
      final row = await _client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();
      if (row != null) return _fromRow(row);
    } catch (e, st) {
      debugPrint('PROFILE LOAD ERROR: ${e.runtimeType}: $e\n$st');
    }

    // Fallback: build the user from signup metadata.
    final fallback = _fromMetadata(authUser);
    if (fallback != null) return fallback;

    // Nothing usable, so don't leave a half-signed-in session behind.
    await _client.auth.signOut();
    throw const AuthException(
        'We could not load your profile. Please try again.');
  }

  AuthUser _fromRow(Map<String, dynamic> row) {
    return AuthUser(
      id: row['id'] as String,
      email: row['email'] as String,
      fullName: row['full_name'] as String,
      birthday: DateTime.parse(row['birthday'] as String),
      gender: row['gender_status'] as String,
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
      try {
        return await _loadProfile(authUser);
      } catch (e, st) {
        debugPrint('PROFILE LOAD ERROR: ${e.runtimeType}: $e\n$st');
        // Don't leave a half-signed-in session behind.
        await _client.auth.signOut();
        throw const AuthException(
            'Signed in, but your profile could not be loaded. Please try again.');
      }
    } on AuthException {
      rethrow;
    } on sb.AuthException catch (e) {
      throw AuthException(_friendly(e.message));
    } catch (e, st) {
      debugPrint('LOGIN ERROR: ${e.runtimeType}: $e\n$st');
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
          'gender_status': genderStatus,
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
      return await _loadProfile(authUser);
    } on AuthException {
      rethrow;
    } on sb.AuthException catch (e) {
      throw AuthException(_friendly(e.message));
    } catch (e, st) {
      debugPrint('REGISTER ERROR: ${e.runtimeType}: $e\n$st');
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