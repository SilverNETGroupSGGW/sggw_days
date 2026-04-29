import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sggw_days/core/widgets/connectivity_banner.dart';
import 'package:sggw_days/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:sggw_days/features/leaderboard/presentation/bloc/leaderboard_event.dart';
import 'package:sggw_days/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_state.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_event.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<TreasureHuntBloc>().add(const LoadTreasurePoints());
    context.read<TimetableBloc>().add(const LoadTimetableEvents());
  }

  void _publishLeaderboardProgress(BuildContext context) {
    final huntState = context.read<TreasureHuntBloc>().state;
    final timetableState = context.read<TimetableBloc>().state;
    context.read<LeaderboardBloc>().add(
      PublishLeaderboardProgress(
        points: huntState.points,
        foundPointIds: huntState.foundPointIds,
        checkedInIds: timetableState.checkedInIds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        BlocListener<TreasureHuntBloc, TreasureHuntState>(
          listenWhen: (previous, current) =>
              previous.foundPointIds != current.foundPointIds ||
              previous.points != current.points,
          listener: (context, state) => _publishLeaderboardProgress(context),
        ),
        BlocListener<TimetableBloc, TimetableState>(
          listenWhen: (previous, current) =>
              previous.checkedInIds != current.checkedInIds,
          listener: (context, state) => _publishLeaderboardProgress(context),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return BlocBuilder<TreasureHuntBloc, TreasureHuntState>(
            builder: (context, huntState) {
              final skipTreasureHunt = settings.skipTreasureHunt;
              final unlocked =
                  skipTreasureHunt || huntState.foundPointIds.isNotEmpty;

              return Scaffold(
                body: ConnectivityBanner(child: widget.navigationShell),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: widget.navigationShell.currentIndex,
                  onDestinationSelected: (index) {
                    if (!unlocked && index != 0 && index != 4) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l10n.appLocked)));
                      return;
                    }
                    widget.navigationShell.goBranch(index);
                  },
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.map),
                      label: l10n.treasureHunt,
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.info,
                        color: unlocked
                            ? null
                            : Theme.of(context).disabledColor,
                      ),
                      label: l10n.wiki,
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.calendar_today,
                        color: unlocked
                            ? null
                            : Theme.of(context).disabledColor,
                      ),
                      label: l10n.timetable,
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.leaderboard,
                        color: unlocked
                            ? null
                            : Theme.of(context).disabledColor,
                      ),
                      label: l10n.leaderboard,
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
      ),
    );
  }
}
