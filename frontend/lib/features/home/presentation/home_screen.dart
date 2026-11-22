import 'package:flutter/material.dart';

import '../../../core/app_router.dart';
import '../../auth/state/auth_scope.dart';

/// Placeholder landing screen. Replace with program search later.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final name = auth.currentUser?.fullName ?? 'there';

    return Scaffold(
      appBar: AppBar(
        title: const Text('GABAY'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await auth.logout();
              navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Hello, $name', style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}