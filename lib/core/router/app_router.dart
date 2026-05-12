import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sggw_days/core/router/error_page.dart';
import 'package:sggw_days/features/admin/presentation/pages/admin_login_page.dart';
import 'package:sggw_days/features/home/presentation/pages/home_page.dart';
import 'package:sggw_days/features/settings/presentation/pages/privacy_policy_page.dart';
import 'package:sggw_days/features/settings/presentation/pages/settings_page.dart';
import 'package:sggw_days/features/timetable/presentation/pages/timetable_page.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_scan_code.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/pages/scan_page.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/pages/treasure_hunt_page.dart';
import 'package:sggw_days/features/wiki/presentation/pages/wiki_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

String? scanRouteRedirectLocation({
  required bool isWeb,
  required String pointId,
}) {
  if (isWeb || !isValidTreasurePointId(pointId)) {
    return null;
  }

  return Uri(path: '/', queryParameters: {'scanPointId': pointId}).toString();
}

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
      redirect: (context, state) => scanRouteRedirectLocation(
        isWeb: kIsWeb,
        pointId: state.pathParameters['pointId']!,
      ),
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
              builder: (context, state) => TreasureHuntPage(
                initialPointId: state.uri.queryParameters['pointId'],
                initialScanPointId: state.uri.queryParameters['scanPointId'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wiki',
              builder: (context, state) => WikiPage(
                initialArticleId: state.uri.queryParameters['articleId'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timetable',
              builder: (context, state) => TimetablePage(
                initialEventId: state.uri.queryParameters['eventId'],
              ),
              routes: [
                GoRoute(
                  path: 'check-in',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) =>
                      const TimetableCheckInScannerPage(),
                ),
              ],
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
