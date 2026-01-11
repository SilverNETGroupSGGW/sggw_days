import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.map),
            label: l10n.treasureHunt,
          ),
          NavigationDestination(icon: const Icon(Icons.info), label: l10n.wiki),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today),
            label: l10n.timetable,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
