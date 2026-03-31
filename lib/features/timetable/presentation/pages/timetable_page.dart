import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  void initState() {
    super.initState();
    context.read<TimetableBloc>().add(const LoadTimetableEvents());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
        onPressed: () => _openCheckInScanner(context),
        icon: const Icon(Icons.qr_code_scanner),
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

          if (state.filteredEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy, size: 100),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.noEventsOn} ${DateFormat.yMMMd().format(state.selectedDate!)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          if (_showTimeline) {
            return _buildTimelineView(context, state);
          }

          return _buildListView(context, state);
        },
      ),
    );
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
                  child: Text(
                    DateFormat.Hm().format(event.startTime),
                    style: const TextStyle(fontSize: 10),
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
                color: isFavorite
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
              onPressed: () {
                context.read<TimetableBloc>().add(
                  ToggleFavorite(event.id),
                );
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

  void _showEventDetails(BuildContext context, dynamic event) {
    final l10n = AppLocalizations.of(context)!;
    final isCheckedIn = context.read<TimetableBloc>().state.checkedInIds
        .contains(event.id as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description as String),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat.Hm().format(event.startTime)} - ${DateFormat.Hm().format(event.endTime)}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(event.location as String)),
              ],
            ),
            if (isCheckedIn) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.checkedIn,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            if (event.imageUrl != null) ...[
              const SizedBox(height: 16),
              Image.network(
                event.imageUrl as String,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _openCheckInScanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<TimetableBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(l10n.checkIn)),
          body: MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue == null) return;
              final code = barcode!.rawValue!;

              // Check if code matches an event ID
              final matchingEvent = bloc.state.events
                  .where((e) => e.id == code)
                  .firstOrNull;

              if (matchingEvent != null) {
                bloc.add(CheckInEvent(code));
                Navigator.pop(context);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.checkedIn}: ${matchingEvent.title}'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
