import 'package:flutter/material.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/point_type_presentation.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/widgets/treasure_hunt_widgets.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class TreasureHuntPointDetailsSheet extends StatelessWidget {
  final TreasurePoint point;
  final bool isFound;
  final bool canScan;
  final String? distanceText;
  final double? distanceMeters;
  final List<WikiArticle> relatedWikis;
  final List<TimetableEvent> relatedEvents;
  final VoidCallback onTrack;
  final VoidCallback onOpenWiki;
  final VoidCallback onOpenTimetable;
  final VoidCallback? onSecondaryAction;
  final IconData secondaryActionIcon;
  final String secondaryActionLabel;

  const TreasureHuntPointDetailsSheet({
    super.key,
    required this.point,
    required this.isFound,
    required this.canScan,
    required this.distanceText,
    required this.distanceMeters,
    required this.relatedWikis,
    required this.relatedEvents,
    required this.onTrack,
    required this.onOpenWiki,
    required this.onOpenTimetable,
    required this.onSecondaryAction,
    required this.secondaryActionIcon,
    required this.secondaryActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typeColor = colorForPointType(point.type, theme.colorScheme);

    return FractionallySizedBox(
      heightFactor: 0.86,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.96,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFound
                              ? Icons.check_circle
                              : iconForPointType(point.type),
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  point.name,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                if (isFound)
                                  StatusPill(
                                    label: l10n.pointFound,
                                    color: theme.colorScheme.primary,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                PointInfoChip(
                                  icon: iconForPointType(point.type),
                                  label: labelForPointType(point.type, l10n),
                                  color: typeColor,
                                ),
                                if (point.type == PointType.treasurePoint)
                                  PointInfoChip(
                                    icon: Icons.emoji_events_outlined,
                                    label: l10n.treasurePointNumber(
                                      point.order + 1,
                                    ),
                                    color: theme.colorScheme.primary,
                                  ),
                                if (distanceText != null)
                                  PointInfoChip(
                                    icon: Icons.straighten,
                                    label: '${l10n.distance}: $distanceText',
                                    color: theme.colorScheme.secondary,
                                  ),
                                if (relatedWikis.isNotEmpty)
                                  PointInfoChip(
                                    icon: Icons.article_outlined,
                                    label:
                                        '${relatedWikis.length} ${l10n.relatedWiki}',
                                    color: theme.colorScheme.secondary,
                                  ),
                                if (relatedEvents.isNotEmpty)
                                  PointInfoChip(
                                    icon: Icons.event_outlined,
                                    label:
                                        '${relatedEvents.length} ${l10n.relatedEvents}',
                                    color: theme.colorScheme.tertiary,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(l10n.about, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      point.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                if (distanceMeters != null &&
                    distanceMeters! <= 80 &&
                    canScan) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${l10n.scanQr} • $distanceText',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (relatedWikis.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  SectionHeader(
                    title: l10n.relatedWiki,
                    actionLabel: l10n.wiki,
                    onAction: onOpenWiki,
                  ),
                  const SizedBox(height: 8),
                  ...relatedWikis
                      .take(3)
                      .map(
                        (article) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PointPreviewTile(
                            icon: Icons.article_outlined,
                            accentColor: theme.colorScheme.secondary,
                            title: article.title,
                            subtitle: article.category,
                            onTap: onOpenWiki,
                          ),
                        ),
                      ),
                ],
                if (relatedEvents.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SectionHeader(
                    title: l10n.relatedEvents,
                    actionLabel: l10n.timetable,
                    onAction: onOpenTimetable,
                  ),
                  const SizedBox(height: 8),
                  ...relatedEvents
                      .take(3)
                      .map(
                        (event) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PointPreviewTile(
                            icon: Icons.event_outlined,
                            accentColor: theme.colorScheme.tertiary,
                            title: event.title,
                            subtitle: _formatEventWindow(event),
                            detail: event.location,
                            onTap: onOpenTimetable,
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.viewPaddingOf(context).bottom + 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onTrack,
                    icon: const Icon(Icons.near_me_rounded),
                    label: Text(l10n.trackOnMap),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSecondaryAction,
                    icon: Icon(secondaryActionIcon),
                    label: Text(secondaryActionLabel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatEventWindow(TimetableEvent event) {
    final startHour = event.startTime.hour.toString().padLeft(2, '0');
    final startMinute = event.startTime.minute.toString().padLeft(2, '0');
    final endHour = event.endTime.hour.toString().padLeft(2, '0');
    final endMinute = event.endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMinute - $endHour:$endMinute';
  }
}
