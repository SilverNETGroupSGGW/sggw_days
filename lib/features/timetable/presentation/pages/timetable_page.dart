import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_state.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
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
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
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
                    'No events on ${DateFormat.yMMMd().format(state.selectedDate!)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.filteredEvents.length,
            itemBuilder: (context, index) {
              final event = state.filteredEvents[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      DateFormat.Hm().format(event.startTime),
                      style: const TextStyle(fontSize: 10),
                    ),
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
                  onTap: () => _showEventDetails(context, event),
                ),
              );
            },
          );
        },
      ),
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
}
