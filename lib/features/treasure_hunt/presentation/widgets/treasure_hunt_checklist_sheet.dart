import 'package:flutter/material.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/point_type_presentation.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/widgets/treasure_hunt_widgets.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class TreasureHuntChecklistSheet extends StatelessWidget {
  final List<TreasurePoint> treasurePoints;
  final List<TreasurePoint> visiblePointsOfInterest;
  final Set<String> foundPointIds;
  final TreasurePoint? nextTreasure;
  final int treasureRemaining;
  final ValueChanged<TreasurePoint> onPointSelected;

  const TreasureHuntChecklistSheet({
    super.key,
    required this.treasurePoints,
    required this.visiblePointsOfInterest,
    required this.foundPointIds,
    required this.nextTreasure,
    required this.treasureRemaining,
    required this.onPointSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.checklist),
                const SizedBox(width: 8),
                Text(l10n.checklist, style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.viewPaddingOf(context).bottom + 16,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(
                    l10n.typeTreasurePoint,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorForPointType(
                        PointType.treasurePoint,
                        theme.colorScheme,
                      ),
                    ),
                  ),
                ),
                ...treasurePoints.where((point) => foundPointIds.contains(point.id)).map(
                  (point) => ChecklistTile(
                    icon: Icons.emoji_events,
                    color: colorForPointType(
                      PointType.treasurePoint,
                      theme.colorScheme,
                    ),
                    title: point.name,
                    isFound: true,
                    onTap: () => onPointSelected(point),
                  ),
                ),
                if (nextTreasure != null)
                  ChecklistTile(
                    icon: Icons.emoji_events,
                    color: colorForPointType(
                      PointType.treasurePoint,
                      theme.colorScheme,
                    ),
                    title: nextTreasure!.name,
                    subtitle: l10n.treasurePointsRemaining(treasureRemaining),
                    isFound: false,
                    onTap: () => onPointSelected(nextTreasure!),
                  )
                else if (treasurePoints.every((point) => foundPointIds.contains(point.id)) &&
                    treasurePoints.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.allTreasurePointsCollected,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                if (visiblePointsOfInterest.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 4),
                    child: Text(
                      l10n.typePointOfInterest,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorForPointType(
                          PointType.pointOfInterest,
                          theme.colorScheme,
                        ),
                      ),
                    ),
                  ),
                  ...visiblePointsOfInterest.map(
                    (point) => ChecklistTile(
                      icon: Icons.place,
                      color: colorForPointType(
                        PointType.pointOfInterest,
                        theme.colorScheme,
                      ),
                      title: point.name,
                      isFound: foundPointIds.contains(point.id),
                      onTap: () => onPointSelected(point),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}