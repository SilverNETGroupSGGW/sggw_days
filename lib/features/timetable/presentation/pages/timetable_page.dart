import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sggw_days/core/icons/material_symbol_catalog.dart';
import 'package:sggw_days/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart'
    as model;
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_state.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  bool _showTimeline = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final skipTreasureHunt = context.select<SettingsCubit, bool>(
      (cubit) => cubit.state.skipTreasureHunt,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timetable),
        actions: [
          BlocBuilder<TimetableBloc, TimetableState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.showFavoritesOnly
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                onPressed: () {
                  context.read<TimetableBloc>().add(
                    const ToggleShowFavorites(),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: Icon(_showTimeline ? Icons.view_list : Icons.view_timeline),
            onPressed: () {
              setState(() {
                _showTimeline = !_showTimeline;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (skipTreasureHunt) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.treasureHuntSkippedCheckInUnavailable),
              ),
            );
            return;
          }
          _openCheckInScanner(context);
        },
        icon: Icon(
          skipTreasureHunt ? Icons.block_rounded : Icons.qr_code_scanner,
        ),
        label: Text(l10n.checkIn),
      ),
      body: BlocConsumer<TimetableBloc, TimetableState>(
        listener: (context, state) {
          if (state.status == TimetableStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == TimetableStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final content = state.filteredEvents.isEmpty
              ? _buildEmptyState(context, state)
              : _showTimeline
              ? _buildTimelineView(context, state)
              : _buildListView(context, state);

          return Column(
            children: [
              _buildDateSelector(context, state),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, TimetableState state) {
    final theme = Theme.of(context);
    final dates = _eventDates(state.events);

    if (dates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      color: theme.colorScheme.surface,
      child: SizedBox(
        height: 94,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final date = dates[index];
            final selected = _isSameDay(date, state.selectedDate);
            final eventCount = state.events
                .where((event) => _isSameDay(event.startTime, date))
                .length;

            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                context.read<TimetableBloc>().add(FilterEventsByDate(date));
              },
              child: SizedBox(
                width: 76,
                height: 78,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 76,
                      height: 78,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat.E().format(date),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: selected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                              height: 1,
                            ),
                          ),
                          Text(
                            DateFormat.d().format(date),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            DateFormat.MMM().format(date),
                            style: theme.textTheme.labelSmall?.copyWith(
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.86,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          child: Text(
                            '$eventCount',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TimetableState state) {
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = state.selectedDate ?? DateTime.now();
    final message = state.showFavoritesOnly
        ? l10n.noFavoriteEventsOn
        : l10n.noEventsOn;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 100),
          const SizedBox(height: 16),
          Text(
            '$message ${DateFormat.yMMMd().format(selectedDate)}',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<DateTime> _eventDates(List<model.TimetableEvent> events) {
    final dates = <DateTime>{
      for (final event in events)
        DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        ),
    }.toList()..sort();
    return dates;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    return a != null &&
        b != null &&
        a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  Widget _buildListView(BuildContext context, TimetableState state) {
    return ListView.builder(
      itemCount: state.filteredEvents.length,
      itemBuilder: (context, index) {
        final event = state.filteredEvents[index];
        final isFavorite = state.favoriteIds.contains(event.id);
        final isCheckedIn = state.checkedInIds.contains(event.id);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  child: Icon(
                    materialSymbolForName(
                      event.iconName,
                      fallback: Symbols.event,
                    ),
                    size: 20,
                  ),
                ),
                if (isCheckedIn)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 10,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(event.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.location),
                Text(
                  '${DateFormat.Hm().format(event.startTime)} - ${DateFormat.Hm().format(event.endTime)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Theme.of(context).colorScheme.error : null,
              ),
              onPressed: () {
                context.read<TimetableBloc>().add(ToggleFavorite(event.id));
              },
            ),
            onTap: () => _showEventDetails(context, event),
          ),
        );
      },
    );
  }

  Widget _buildTimelineView(BuildContext context, TimetableState state) {
    final theme = Theme.of(context);
    final events = List.of(state.filteredEvents)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isFavorite = state.favoriteIds.contains(event.id);
        final duration = event.endTime.difference(event.startTime);
        final durationText = duration.inMinutes >= 60
            ? '${duration.inHours}h ${duration.inMinutes % 60}m'
            : '${duration.inMinutes}m';

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time column
              SizedBox(
                width: 56,
                child: Text(
                  DateFormat.Hm().format(event.startTime),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Timeline line
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index < events.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Event card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    child: InkWell(
                      onTap: () => _showEventDetails(context, event),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  materialSymbolForName(
                                    event.iconName,
                                    fallback: Symbols.event,
                                  ),
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    event.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 20,
                                    color: isFavorite
                                        ? theme.colorScheme.error
                                        : null,
                                  ),
                                  onPressed: () {
                                    context.read<TimetableBloc>().add(
                                      ToggleFavorite(event.id),
                                    );
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  durationText,
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    style: theme.textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final bloc = context.read<TimetableBloc>();
    final currentDate = bloc.state.selectedDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      bloc.add(FilterEventsByDate(picked));
    }
  }

  void _showEventDetails(BuildContext context, model.TimetableEvent event) {
    final l10n = AppLocalizations.of(context)!;
    final isCheckedIn = context
        .read<TimetableBloc>()
        .state
        .checkedInIds
        .contains(event.id);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              20 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _EventImageBanner(
                  imageUrl: event.imageUrl,
                  iconName: event.iconName,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.access_time,
                      label:
                          '${DateFormat.Hm().format(event.startTime)} - ${DateFormat.Hm().format(event.endTime)}',
                    ),
                    _InfoChip(icon: Icons.location_on, label: event.location),
                    if (isCheckedIn)
                      _InfoChip(
                        icon: Icons.check_circle,
                        label: l10n.checkedIn,
                      ),
                  ],
                ),
                if (event.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.eventTags,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: event.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  event.description,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCheckInScanner(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (context.read<SettingsCubit>().state.skipTreasureHunt) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.treasureHuntSkippedCheckInUnavailable)),
      );
      return;
    }

    final bloc = context.read<TimetableBloc>();

    final eventId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => _CheckInScannerPage(
          validEventIds: bloc.state.events.map((event) => event.id).toSet(),
        ),
      ),
    );

    if (!context.mounted || eventId == null) return;

    final matchingEvent = bloc.state.events
        .where((event) => event.id == eventId)
        .firstOrNull;
    if (matchingEvent == null) return;

    bloc.add(CheckInEvent(eventId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.checkedIn}: ${matchingEvent.title}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _CheckInScannerPage extends StatefulWidget {
  final Set<String> validEventIds;

  const _CheckInScannerPage({required this.validEventIds});

  @override
  State<_CheckInScannerPage> createState() => _CheckInScannerPageState();
}

class _CheckInScannerPageState extends State<_CheckInScannerPage> {
  late final MobileScannerController _controller;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeScan(String code) async {
    if (!mounted || _isClosing) return;
    _isClosing = true;
    await _controller.stop();
    if (!mounted) return;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkIn)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_isClosing) return;

              final barcode = capture.barcodes.firstOrNull;
              final code = barcode?.rawValue;
              if (code == null || !widget.validEventIds.contains(code)) {
                return;
              }

              unawaited(_completeScan(code));
            },
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              final isReady =
                  state.isInitialized && state.isRunning && state.error == null;
              if (isReady) {
                return const SizedBox.shrink();
              }

              return Container(
                color: Colors.black.withValues(alpha: 0.85),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      l10n.cameraLoading,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EventImageBanner extends StatelessWidget {
  final String? imageUrl;
  final String? iconName;

  const _EventImageBanner({required this.imageUrl, required this.iconName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: double.infinity,
          height: 124,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              materialSymbolForName(iconName, fallback: Symbols.event_note),
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              materialSymbolForName(iconName, fallback: Symbols.event_note),
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.primary),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.65,
      ),
    );
  }
}
