import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'core/app_router.dart';
import 'core/config/supabase_config.dart';
import 'core/l10n/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/supabase_auth_repository.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/auth/state/auth_scope.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/state/profile_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
    throw StateError('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
  }
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const GabayApp());
}

class GabayApp extends StatefulWidget {
  const GabayApp({super.key});

  @override
  State<GabayApp> createState() => _GabayAppState();
}

class _GabayAppState extends State<GabayApp> {
  final _client = Supabase.instance.client;

  late final AuthController _auth =
  AuthController(SupabaseAuthRepository(_client));
  late final ProfileController _profile =
  ProfileController(ProfileRepository(_client));
  final LanguageController _language = LanguageController();

  @override
  void dispose() {
    _auth.dispose();
    _profile.dispose();
    _language.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LanguageScope(
      controller: _language,
      child: AuthScope(
        controller: _auth,
        child: ProfileScope(
          controller: _profile,
          child: MaterialApp(
            title: 'GABAY',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            // Supabase keeps the session, so returning users skip the login.
            initialRoute: _auth.currentUser != null
                ? AppRoutes.home
                : AppRoutes.login,
            routes: AppRoutes.routes,
          ),
        ),
      ),
    );
  }
}