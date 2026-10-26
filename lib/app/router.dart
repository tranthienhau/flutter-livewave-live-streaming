import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/creator_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/go_live_screen.dart';
import '../screens/home_screen.dart';
import '../screens/host_live_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stream_health_screen.dart';
import '../screens/summary_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/watch_screen.dart';
import '../screens/welcome_screen.dart';
import '../widgets/tab_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => TabShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (_, _) => const ExploreScreen(),
              routes: [
                GoRoute(
                  path: 'creator/:id',
                  builder: (_, s) => CreatorScreen(id: s.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/golive', builder: (_, _) => const GoLiveScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (_, _) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'settings',
                  builder: (_, _) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/watch/:id',
      builder: (_, s) => WatchScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(path: '/host', builder: (_, _) => const HostLiveScreen()),
    GoRoute(path: '/health', builder: (_, _) => const StreamHealthScreen()),
    GoRoute(path: '/summary', builder: (_, _) => const SummaryScreen()),
  ],
  errorBuilder: (_, s) =>
      Scaffold(body: Center(child: Text('Not found: ${s.uri}'))),
);
