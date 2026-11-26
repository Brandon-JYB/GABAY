import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/user_profile.dart';

/// Reads and writes the signed-in user's row in the `users` table.
class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<UserProfile> fetch() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return const UserProfile();

    final row =
    await _client.from('users').select().eq('id', id).maybeSingle();
    if (row == null) return const UserProfile();

    final birthday = row['birthday'] as String?;
    return UserProfile(
      name: (row['full_name'] as String?) ?? '',
      birthday: birthday == null ? null : DateTime.parse(birthday),
      gender: row['gender_status'] as String?,
      civilStatus: row['civil_status'] as String?,
      sitio: (row['sitio'] as String?) ?? '',
      barangay: (row['barangay'] as String?) ?? '',
      // Register only collects sitio and barangay (the city is always
      isPhilhealth: row['is_philhealth_member'] as bool?,
      isPwd: row['is_pwd'] as bool?,
    );
  }

  Future<void> save(UserProfile p) async {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Not signed in');

    await _client.from('users').upsert({
      'id': id,
      'email': _client.auth.currentUser?.email,
      'full_name': _nullIfEmpty(p.name),
      'birthday': p.birthday == null ? null : _dateOnly(p.birthday!),
      'gender_status': p.gender,
      'civil_status': p.civilStatus,
      'sitio': _nullIfEmpty(p.sitio),
      'barangay': _nullIfEmpty(p.barangay),
      'is_philhealth_member': p.isPhilhealth,
      'is_pwd': p.isPwd,
    });
  }

  String _orDefault(String? v, String fallback) =>
      (v == null || v.trim().isEmpty) ? fallback : v.trim();

  String? _nullIfEmpty(String v) => v.trim().isEmpty ? null : v.trim();

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
}
