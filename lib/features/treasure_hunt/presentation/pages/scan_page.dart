import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_event.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class ScanPage extends StatefulWidget {
  final String pointId;

  const ScanPage({super.key, required this.pointId});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<TreasureHuntBloc>();
    if (bloc.state.status != TreasureHuntStatus.success) {
      bloc.add(const LoadTreasurePoints());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanPageTitle)),
      body: BlocBuilder<TreasureHuntBloc, TreasureHuntState>(
        builder: (context, state) {
          if (state.status == TreasureHuntStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final point = state.points
              .where((p) => p.id == widget.pointId)
              .firstOrNull;

          final isCollected =
              point != null && state.foundPointIds.contains(point.id);

          if (point == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.scanPagePointNotFound,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.go('/'),
                      child: Text(l10n.goHome),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCollected ? Icons.check_circle : Icons.location_on,
                    size: 80,
                    color: isCollected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    point.name,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    point.description,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (isCollected) ...[
                    const SizedBox(height: 20),
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.pointFound,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          l10n.scanPageDesc,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.scanPageOpenApp),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
