import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sggw_days/core/icons/material_symbol_catalog.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/point_type_presentation.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/widgets/treasure_hunt_widgets.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_bloc.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class TreasureHuntPointDetailsSheet extends StatelessWidget {
  final TreasurePoint point;
  final bool isFound;
  final bool showTreasureIcon;
  final bool canScan;
  final String? distanceText;
  final double? distanceMeters;
  final VoidCallback onTrack;
  final VoidCallback onOpenWiki;
  final ValueChanged<WikiArticle> onOpenWikiArticle;
  final VoidCallback onOpenTimetable;
  final ValueChanged<TimetableEvent> onOpenTimetableEvent;
  final VoidCallback? onSecondaryAction;
  final IconData secondaryActionIcon;
  final String secondaryActionLabel;

  const TreasureHuntPointDetailsSheet({
    super.key,
    required this.point,
    required this.isFound,
    required this.showTreasureIcon,
    required this.canScan,
    required this.distanceText,
    required this.distanceMeters,
    required this.onTrack,
    required this.onOpenWiki,
    required this.onOpenWikiArticle,
    required this.onOpenTimetable,
    required this.onOpenTimetableEvent,
    required this.onSecondaryAction,
    required this.secondaryActionIcon,
    required this.secondaryActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typeColor = colorForMapPoint(
      point,
      theme.colorScheme,
      useTreasureColor: showTreasureIcon,
    );
    final pointIcon = iconForMapPoint(point, useTreasureIcon: showTreasureIcon);
    final relatedWikis = context
        .watch<WikiBloc>()
        .state
        .articles
        .where((article) => article.treasurePointIds.contains(point.id))
        .toList();
    final relatedEvents = context
        .watch<TimetableBloc>()
        .state
        .events
        .where((event) => event.treasurePointIds.contains(point.id))
        .toList();

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
                        child: Icon(pointIcon, color: typeColor),
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
                                  icon: pointIcon,
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
                                    color: theme.colorScheme.primary,
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
                if (point.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        point.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                              child: Icon(
                                pointIcon,
                                size: 48,
                                color: typeColor,
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
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
                  const SizedBox(height: 14),
                  SectionHeader(
                    title: l10n.relatedWiki,
                    actionLabel: l10n.wiki,
                    onAction: onOpenWiki,
                  ),
                  const SizedBox(height: 8),
                  ...relatedWikis.map(
                    (article) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PointPreviewTile(
                        icon: materialSymbolForName(
                          article.iconName,
                          fallback: Icons.article_outlined,
                        ),
                        accentColor: theme.colorScheme.secondary,
                        title: article.title,
                        subtitle: article.category,
                        onTap: () => onOpenWikiArticle(article),
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
                  ...relatedEvents.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PointPreviewTile(
                        icon: materialSymbolForName(
                          event.iconName,
                          fallback: Icons.event_outlined,
                        ),
                        accentColor: theme.colorScheme.primary,
                        title: event.title,
                        subtitle: _formatEventWindow(context, event),
                        detail: event.location,
                        onTap: () => onOpenTimetableEvent(event),
                      ),
                    ),
                  ),
                ],
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

  String _formatEventWindow(BuildContext context, TimetableEvent event) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateText = DateFormat.MMMd(locale).format(event.startTime);
    final startText = DateFormat.Hm(locale).format(event.startTime);
    final endText = DateFormat.Hm(locale).format(event.endTime);
    return '$dateText, $startText - $endText';
  }
}
