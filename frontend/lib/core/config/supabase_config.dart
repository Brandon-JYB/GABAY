import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Values come from the .env file in the project root (next to pubspec.yaml):
///   SUPABASE_URL=https://xxxx.supabase.co
///   SUPABASE_ANON_KEY=your-anon-key
/// The anon key is meant to be in the app (RLS protects the data).
/// NEVER put the service_role key here or in .env.
class SupabaseConfig {
  SupabaseConfig._();

  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}