import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sggw_days/features/admin/presentation/pages/admin_page.dart';
import 'package:sggw_days/features/home/presentation/pages/home_page.dart';
import 'package:sggw_days/features/settings/presentation/pages/settings_page.dart';
import 'package:sggw_days/features/timetable/presentation/pages/timetable_page.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/pages/treasure_hunt_page.dart';
import 'package:sggw_days/features/wiki/presentation/pages/wiki_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: rootNavigatorKey,
  routes: [
    GoRoute(path: '/admin', builder: (context, state) => const AdminPage()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomePage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const TreasureHuntPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wiki',
              builder: (context, state) => const WikiPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timetable',
              builder: (context, state) => const TimetablePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
