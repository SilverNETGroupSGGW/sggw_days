import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sggw_days/core/router/error_page.dart';
import 'package:sggw_days/features/admin/presentation/pages/admin_login_page.dart';
import 'package:sggw_days/features/home/presentation/pages/home_page.dart';
import 'package:sggw_days/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:sggw_days/features/settings/presentation/pages/privacy_policy_page.dart';
import 'package:sggw_days/features/settings/presentation/pages/settings_page.dart';
import 'package:sggw_days/features/timetable/presentation/pages/timetable_page.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/pages/scan_page.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/pages/treasure_hunt_page.dart';
import 'package:sggw_days/features/wiki/presentation/pages/wiki_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: rootNavigatorKey,
  errorBuilder: (context, state) => ErrorPage(error: state.error),
  routes: [
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminLoginPage(),
    ),
    GoRoute(
      path: '/scan/:pointId',
      builder: (context, state) =>
          ScanPage(pointId: state.pathParameters['pointId']!),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
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
              path: '/leaderboard',
              builder: (context, state) => const LeaderboardPage(),
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
