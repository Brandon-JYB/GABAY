import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/program.dart';

/// Reads the `programs` table in Supabase.
class ProgramRepository {
  ProgramRepository(this._client);

  final SupabaseClient _client;

  Future<List<Program>> fetchAll() async {
    final rows = await _client.from('programs').select().order('id');
    return [for (final row in rows) Program.fromRow(row)];
  }
}