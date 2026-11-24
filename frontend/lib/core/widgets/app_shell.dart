import 'package:flutter/material.dart';

import '../../features/auth/state/auth_scope.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/state/profile_controller.dart';
import '../../features/programs/presentation/programs_screen.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Shared layout for the main tabs: Home, Programs, Ask GABAY.
/// Profile is not a tab. It opens from the button at the top right of Home.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0, this.onProfileTap});

  final int initialIndex;
  final VoidCallback? onProfileTap;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    // Load after the first frame so listeners aren't notified mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ProfileScope.of(context).load();
    });
  }

  void _goTo(int index) => setState(() => _index = index);

  String? _firstName(String fullName) {
    final trimmed = fullName.trim();
    return trimmed.isEmpty ? null : trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    // Replace the placeholder with the real AI screen when it exists.
    final profileName = ProfileScope.of(context).profile.name;
    final accountName = AuthScope.of(context).currentUser?.fullName ?? '';

    final pages = <Widget>[
      HomeScreen(
        userName: _firstName(profileName) ?? _firstName(accountName),
        onProfileTap: widget.onProfileTap,
        onFindPrograms: () => _goTo(1),
        onCheckEligibility: () => _goTo(1),
        onViewAllPrograms: () => _goTo(1),
        onAskGabay: () => _goTo(2),
      ),
      const ProgramsScreen(),
      _TabPlaceholder(context.tr('askGabay')),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.lightGray)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goTo,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: context.tr('navHome'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.description_outlined),
              selectedIcon: const Icon(Icons.description_rounded),
              label: context.tr('navPrograms'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_awesome_outlined),
              selectedIcon: const Icon(Icons.auto_awesome),
              label: context.tr('navAsk'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(context.tr('comingSoon'))),
    );
  }
}