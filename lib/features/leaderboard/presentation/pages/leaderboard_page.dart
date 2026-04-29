import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/features/leaderboard/data/models/leaderboard_entry.dart';
import 'package:sggw_days/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:sggw_days/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:sggw_days/features/leaderboard/presentation/bloc/leaderboard_event.dart';
import 'package:sggw_days/features/leaderboard/presentation/bloc/leaderboard_state.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.leaderboard),
          actions: [
            IconButton(
              onPressed: () => _showEditNameDialog(context),
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.leaderboardEditName,
            ),
          ],
        ),
        body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
          builder: (context, state) {
            if (state.status == LeaderboardStatus.loading &&
                state.overallEntries.isEmpty &&
                state.treasureEntries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                _ParticipantPanel(state: state),
                Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: TabBar(
                    tabs: [
                      Tab(text: l10n.leaderboardOverall),
                      Tab(text: l10n.leaderboardTreasureHunt),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _LeaderboardList(
                        entries: state.overallEntries,
                        participantId: state.participantId,
                        mode: LeaderboardMode.overall,
                      ),
                      _LeaderboardList(
                        entries: state.treasureEntries,
                        participantId: state.participantId,
                        mode: LeaderboardMode.treasureHunt,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<LeaderboardBloc>();
    final controller = TextEditingController(text: bloc.state.displayName);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.leaderboardEditName),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 24,
            decoration: InputDecoration(
              labelText: l10n.leaderboardDisplayName,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _saveDisplayName(dialogContext, controller),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => _saveDisplayName(dialogContext, controller),
              child: Text(l10n.leaderboardSaveName),
            ),
          ],
        );
      },
    );
  }

  void _saveDisplayName(
    BuildContext dialogContext,
    TextEditingController controller,
  ) {
    final name = controller.text.trim();
    if (name.isEmpty) return;
    dialogContext.read<LeaderboardBloc>().add(
      UpdateLeaderboardDisplayName(name),
    );
    Navigator.pop(dialogContext);
  }
}

class _ParticipantPanel extends StatelessWidget {
  const _ParticipantPanel({required this.state});

  final LeaderboardState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final entry = state.currentOverallEntry;

    return Material(
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              child: const Icon(Icons.person),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _MetricChip(
                        icon: Icons.stars_outlined,
                        label: l10n.leaderboardScore(entry?.totalScore ?? 0),
                      ),
                      _MetricChip(
                        icon: Icons.place_outlined,
                        label: l10n.leaderboardFoundPoints(
                          entry?.foundPointScore ?? 0,
                        ),
                      ),
                      _MetricChip(
                        icon: Icons.event_available_outlined,
                        label: l10n.leaderboardCheckIns(
                          entry?.checkInScore ?? 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({
    required this.entries,
    required this.participantId,
    required this.mode,
  });

  final List<LeaderboardEntry> entries;
  final String? participantId;
  final LeaderboardMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.leaderboard_outlined, size: 72),
            const SizedBox(height: 12),
            Text(
              l10n.leaderboardNoEntries,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isCurrentUser = entry.participantId == participantId;
        return _LeaderboardRow(
          rank: index + 1,
          entry: entry,
          isCurrentUser: isCurrentUser,
          mode: mode,
        );
      },
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
    required this.mode,
  });

  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final LeaderboardMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final score = mode == LeaderboardMode.overall
        ? entry.totalScore
        : entry.treasureScore;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: isCurrentUser
          ? colors.primaryContainer.withValues(alpha: 0.62)
          : colors.surfaceContainerHighest.withValues(alpha: 0.5),
      leading: SizedBox.square(
        dimension: 42,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: rank <= 3 ? colors.primary : colors.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: theme.textTheme.labelLarge?.copyWith(
                color: rank <= 3
                    ? colors.onPrimary
                    : colors.onSecondaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              entry.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isCurrentUser ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            Text(
              l10n.leaderboardYou,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        mode == LeaderboardMode.overall
            ? '${l10n.leaderboardFoundPoints(entry.foundPointScore)} / ${l10n.leaderboardCheckIns(entry.checkInScore)}'
            : '${l10n.leaderboardTreasurePoints(entry.treasureScore)} / ${l10n.leaderboardScore(entry.totalScore)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        l10n.leaderboardScore(score),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: colors.primary,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
