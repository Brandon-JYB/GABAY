import 'package:flutter/material.dart';

import 'core/app_router.dart';
import 'features/auth/data/mock_auth_repository.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/auth/state/auth_scope.dart';

void main() => runApp(const GabayApp());

class GabayApp extends StatefulWidget {
  const GabayApp({super.key});

  @override
  State<GabayApp> createState() => _GabayAppState();
}

class _GabayAppState extends State<GabayApp> {
  // Swap MockAuthRepository for the real implementation once the backend is chosen.
  late final AuthController _auth = AuthController(MockAuthRepository());

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: _auth,
      child: MaterialApp(
        title: 'GABAY',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F7D5C)),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}