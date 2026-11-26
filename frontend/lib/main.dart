import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show Supabase, AuthChangeEvent;

import 'core/app_router.dart';
import 'core/config/supabase_config.dart';
import 'core/l10n/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/supabase_auth_repository.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/auth/state/auth_scope.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/state/profile_controller.dart';
import 'features/programs/data/program_repository.dart';
import 'features/programs/state/programs_controller.dart';
import 'features/programs/state/saved_programs_controller.dart';

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
  late final ProgramsController _programs =
  ProgramsController(ProgramRepository(_client));
  final SavedProgramsController _saved = SavedProgramsController();
  final LanguageController _language = LanguageController();

  StreamSubscription? _authSub;

  @override
  void initState() {
    super.initState();
    // Keeps profile in sync with auth: load after register/login, clear on logout.
    _authSub = _client.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.initialSession:
        case AuthChangeEvent.signedIn:
          if (data.session != null) {
            _profile.load();
            _saved.load();
          }
          break;
        case AuthChangeEvent.signedOut:
          _profile.clear();
          _saved.clear();
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _auth.dispose();
    _profile.dispose();
    _programs.dispose();
    _saved.dispose();
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
          child: ProgramsScope(
            controller: _programs,
            child: SavedProgramsScope(
              controller: _saved,
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
        ),
      ),
    );
  }
}