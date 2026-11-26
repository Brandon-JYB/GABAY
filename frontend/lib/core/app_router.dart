import 'package:flutter/widgets.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import 'widgets/app_shell.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    // Opens the shared tab layout (Home, Programs, Ask GABAY).
    home: (context) => AppShell(
      onProfileTap: () => Navigator.pushNamed(context, profile),
    ),
    profile: (_) => const ProfileScreen(),
  };
}