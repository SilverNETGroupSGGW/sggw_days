import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sggw_days/core/widgets/connectivity_banner.dart';
import 'package:sggw_days/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<TreasureHuntBloc, TreasureHuntState>(
          builder: (context, huntState) {
            final skipTreasureHunt = settings.skipTreasureHunt;
            final unlocked =
                skipTreasureHunt || huntState.foundPointIds.isNotEmpty;

            return Scaffold(
              body: ConnectivityBanner(child: navigationShell),
              bottomNavigationBar: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) {
                  if (!unlocked && index != 0 && index != 3) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.appLocked)));
                    return;
                  }
                  navigationShell.goBranch(index);
                },
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.map),
                    label: l10n.treasureHunt,
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.info,
                      color: unlocked ? null : Theme.of(context).disabledColor,
                    ),
                    label: l10n.wiki,
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.calendar_today,
                      color: unlocked ? null : Theme.of(context).disabledColor,
                    ),
                    label: l10n.timetable,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings),
                    label: l10n.settings,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
