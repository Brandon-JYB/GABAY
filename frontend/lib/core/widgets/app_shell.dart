import 'package:flutter/material.dart';

import '../../features/auth/state/auth_scope.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/state/profile_controller.dart';
import '../../features/programs/state/programs_controller.dart';
import '../../features/programs/presentation/programs_screen.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import 'app_tutorial.dart';
import 'language_toggle.dart';

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

  /// Bumped by Home's "Check eligibility" so Programs opens with
  /// "Match my profile" switched on.
  int _matchRequest = 0;

  @override
  void initState() {
    super.initState();
    // Load after the first frame so listeners aren't notified mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ProfileScope.of(context).load();
      ProgramsScope.of(context).load();
      AppTutorial.showIfFirstTime(context);
    });
  }

  void _goTo(int index) => setState(() => _index = index);

  String? _firstName(String fullName) {
    final trimmed = fullName.trim();
    return trimmed.isEmpty ? null : trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final profileName = ProfileScope.of(context).profile.name;
    final accountName = AuthScope.of(context).currentUser?.fullName ?? '';

    final pages = <Widget>[
      HomeScreen(
        userName: _firstName(profileName) ?? _firstName(accountName),
        onProfileTap: widget.onProfileTap,
        onFindPrograms: () => _goTo(1),
        onCheckEligibility: () => setState(() {
          _matchRequest++;
          _index = 1;
        }),
        onViewAllPrograms: () => _goTo(1),
        onAskGabay: () => _goTo(2),
      ),
      ProgramsScreen(matchProfileRequest: _matchRequest),
      // Placeholder until the AI chat exists. The FAQ lives on Home's quick actions.
      const _AskGabayPlaceholder(),
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

/// Empty Ask GABAY tab. Replace with the AI chat later.
class _AskGabayPlaceholder extends StatelessWidget {
  const _AskGabayPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('askGabay'),
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.phthalo,
                      ),
                    ),
                  ),
                  const LanguageToggle(),
                ],
              ),
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_outlined,
                          size: 48, color: AppColors.deepSpace),
                      SizedBox(height: 12),
                      Text(
                        'Coming soon',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}