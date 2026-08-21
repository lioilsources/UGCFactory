import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modules/composer/composer_screen.dart';
import '../modules/queue/queue_screen.dart';
import '../modules/settings/settings_screen.dart';
import '../modules/triage/triage_screen.dart';

final router = GoRouter(
  initialLocation: '/triage',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _Shell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/composer', builder: (c, s) => const ComposerScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/queue', builder: (c, s) => const QueueScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/triage', builder: (c, s) => const TriageScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        ]),
      ],
    ),
  ],
);

class _Shell extends StatelessWidget {
  const _Shell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Composer'),
          NavigationDestination(icon: Icon(Icons.playlist_play), label: 'Fronta'),
          NavigationDestination(icon: Icon(Icons.swipe), label: 'Triage'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Nastaveni'),
        ],
      ),
    );
  }
}
