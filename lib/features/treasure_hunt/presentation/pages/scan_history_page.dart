import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class ScanHistoryPage extends StatelessWidget {
  const ScanHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanHistory)),
      body: BlocBuilder<TreasureHuntBloc, TreasureHuntState>(
        builder: (context, state) {
          final foundPoints = state.points
              .where((p) => state.foundPointIds.contains(p.id))
              .toList();

          // Sort by scan time (most recent first)
          foundPoints.sort((a, b) {
            final timeA = state.scanHistory[a.id];
            final timeB = state.scanHistory[b.id];
            if (timeA == null && timeB == null) return 0;
            if (timeA == null) return 1;
            if (timeB == null) return -1;
            return timeB.compareTo(timeA);
          });

          if (foundPoints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noScansYet,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: foundPoints.length,
            itemBuilder: (context, index) {
              final point = foundPoints[index];
              final scanTime = state.scanHistory[point.id];
              final dateFormat = DateFormat.yMd().add_Hm();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(point.name),
                subtitle: scanTime != null
                    ? Text(dateFormat.format(scanTime))
                    : null,
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              );
            },
          );
        },
      ),
    );
  }
}
