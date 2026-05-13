import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/notifications/data/event_reminder_service.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart'
    as model;
import 'package:sggw_days/features/timetable/data/repositories/timetable_repository.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_state.dart';

class _StreamingTimetableRepository extends TimetableRepository {
  final StreamController<List<model.TimetableEvent>> controller =
      StreamController<List<model.TimetableEvent>>();

  @override
  Future<List<model.TimetableEvent>> getEvents() async => const [];

  @override
  Stream<List<model.TimetableEvent>> watchEvents() => controller.stream;
}

class _ReminderSyncCall {
  const _ReminderSyncCall({required this.events, required this.favoriteIds});

  final List<model.TimetableEvent> events;
  final List<String> favoriteIds;
}

class _RecordingEventReminderService extends EventReminderService {
  _RecordingEventReminderService({required super.settingsBox});

  final StreamController<_ReminderSyncCall> _syncController =
      StreamController<_ReminderSyncCall>.broadcast();

  Stream<_ReminderSyncCall> get syncs => _syncController.stream;

  @override
  bool get remindersEnabled => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleFavoriteEventReminders(
    List<model.TimetableEvent> events,
    Iterable<String> favoriteIds,
  ) async {
    _syncController.add(
      _ReminderSyncCall(
        events: List<model.TimetableEvent>.from(events),
        favoriteIds: List<String>.from(favoriteIds),
      ),
    );
  }

  Future<void> closeRecorder() async {
    await _syncController.close();
  }
}

void main() {
  late Directory tempDirectory;

  setUpAll(() {
    tempDirectory = Directory.systemTemp.createTempSync(
      'sggw_days_timetable_bloc_test_',
    );
    Hive.init(tempDirectory.path);
  });

  tearDown(() async {
    if (Hive.isBoxOpen('favorites')) {
      await Hive.box<List<String>>('favorites').close();
    }
    if (Hive.isBoxOpen('check_ins')) {
      await Hive.box<List<String>>('check_ins').close();
    }
    if (Hive.isBoxOpen('event_check_in_history')) {
      await Hive.box('event_check_in_history').close();
    }
    if (Hive.isBoxOpen('settings')) {
      await Hive.box('settings').close();
    }
    await Hive.deleteBoxFromDisk('favorites');
    await Hive.deleteBoxFromDisk('check_ins');
    await Hive.deleteBoxFromDisk('event_check_in_history');
    await Hive.deleteBoxFromDisk('settings');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test('keeps selected date and favorites when events change', () async {
    final selectedDay = DateTime(2026, 5, 20);
    final favorite = _event(
      id: 'favorite',
      title: 'Favorite Event',
      startTime: selectedDay,
      tags: const ['science'],
    );
    final otherDay = _event(
      id: 'other-day',
      title: 'Other Day',
      startTime: DateTime(2026, 5, 21),
      tags: const ['science'],
    );
    final updatedFavorite = _event(
      id: 'favorite',
      title: 'Updated Favorite Event',
      startTime: selectedDay,
      tags: const ['science'],
    );

    final favoritesBox = await Hive.openBox<List<String>>('favorites');
    await favoritesBox.put('timetable_favorites', const ['favorite']);
    final repository = _StreamingTimetableRepository();
    final bloc = TimetableBloc(repository: repository);

    final firstSnapshot = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TimetableState>().having(
          (state) => state.events.length,
          'event count',
          2,
        ),
      ),
    );
    bloc.add(const LoadTimetableEvents());
    bloc.add(FilterEventsByDate(selectedDay));
    bloc.add(const ToggleShowFavorites());
    repository.controller.add([favorite, otherDay]);
    await firstSnapshot;

    final updatedSnapshot = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TimetableState>()
            .having(
              (state) => state.filteredEvents.map((event) => event.title),
              'filtered titles',
              ['Updated Favorite Event'],
            )
            .having((state) => state.favoriteIds, 'favorites', const [
              'favorite',
            ])
            .having(
              (state) => state.showFavoritesOnly,
              'show favorites only',
              isTrue,
            ),
      ),
    );
    repository.controller.add([updatedFavorite, otherDay]);
    await updatedSnapshot;

    await bloc.close();
    await repository.controller.close();
  });

  test('records a timestamp when checking in to an event', () async {
    final event = _event(
      id: 'event-1',
      title: 'Open Lab',
      startTime: DateTime(2026, 5, 20),
      tags: const ['science'],
    );
    final repository = _StreamingTimetableRepository();
    final bloc = TimetableBloc(repository: repository);

    final loaded = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TimetableState>().having(
          (state) => state.events.single.id,
          'event id',
          'event-1',
        ),
      ),
    );
    bloc.add(const LoadTimetableEvents());
    repository.controller.add([event]);
    await loaded;

    final checkedIn = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TimetableState>()
            .having((state) => state.checkedInIds, 'checked in ids', [
              'event-1',
            ])
            .having(
              (state) => state.checkedInHistory.containsKey('event-1'),
              'has check-in timestamp',
              isTrue,
            ),
      ),
    );
    bloc.add(const CheckInEvent('event-1'));
    await checkedIn;

    final historyBox = await Hive.openBox('event_check_in_history');
    expect(historyBox.get('event-1'), isA<String>());

    await bloc.close();
    await repository.controller.close();
  });

  test('migrates existing check-ins into timestamp history', () async {
    final event = _event(
      id: 'legacy-event',
      title: 'Legacy Event',
      startTime: DateTime(2026, 5, 20),
      tags: const ['science'],
    );
    final checkInBox = await Hive.openBox<List<String>>('check_ins');
    await checkInBox.put('event_check_ins', const ['legacy-event']);
    final repository = _StreamingTimetableRepository();
    final bloc = TimetableBloc(repository: repository);

    final loaded = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TimetableState>()
            .having((state) => state.checkedInIds, 'checked in ids', [
              'legacy-event',
            ])
            .having(
              (state) => state.checkedInHistory.containsKey('legacy-event'),
              'migrated check-in timestamp',
              isTrue,
            ),
      ),
    );
    bloc.add(const LoadTimetableEvents());
    repository.controller.add([event]);
    await loaded;

    final historyBox = await Hive.openBox('event_check_in_history');
    expect(
      DateTime.tryParse(historyBox.get('legacy-event') as String),
      isNotNull,
    );

    await bloc.close();
    await repository.controller.close();
  });

  test('sorts loaded events by start time', () async {
    final repository = _StreamingTimetableRepository();
    final bloc = TimetableBloc(repository: repository);
    final day = DateTime(2026, 5, 20);
    final lateEvent = _event(
      id: 'late',
      title: 'Late Event',
      startTime: DateTime(day.year, day.month, day.day, 12),
      tags: const ['science'],
    );
    final earlyEvent = _event(
      id: 'early',
      title: 'Early Event',
      startTime: DateTime(day.year, day.month, day.day, 9),
      tags: const ['science'],
    );
    final midEvent = _event(
      id: 'mid',
      title: 'Mid Event',
      startTime: DateTime(day.year, day.month, day.day, 10, 30),
      tags: const ['science'],
    );

    final loaded = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TimetableState>()
            .having(
              (state) => state.events.map((event) => event.title).toList(),
              'sorted events',
              ['Early Event', 'Mid Event', 'Late Event'],
            )
            .having(
              (state) =>
                  state.filteredEvents.map((event) => event.title).toList(),
              'sorted filtered events',
              ['Early Event', 'Mid Event', 'Late Event'],
            ),
      ),
    );

    bloc.add(const LoadTimetableEvents());
    repository.controller.add([lateEvent, earlyEvent, midEvent]);
    await loaded;

    await bloc.close();
    await repository.controller.close();
  });

  test('syncs reminders when an event is favorited', () async {
    final repository = _StreamingTimetableRepository();
    final settingsBox = await Hive.openBox('settings');
    final reminderService = _RecordingEventReminderService(
      settingsBox: settingsBox,
    );
    final bloc = TimetableBloc(
      repository: repository,
      eventReminderService: reminderService,
    );
    final event = _event(
      id: 'event-1',
      title: 'Open Lab',
      startTime: DateTime(2026, 5, 20, 11),
      tags: const ['science'],
    );

    final loaded = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TimetableState>().having(
          (state) => state.events.single.id,
          'event id',
          'event-1',
        ),
      ),
    );

    bloc.add(const LoadTimetableEvents());
    repository.controller.add([event]);
    await loaded;

    final reminderSync = reminderService.syncs.firstWhere(
      (call) => call.favoriteIds.contains('event-1'),
    );
    bloc.add(const ToggleFavorite('event-1'));

    final syncCall = await reminderSync;
    expect(syncCall.favoriteIds, ['event-1']);
    expect(syncCall.events.map((item) => item.id), ['event-1']);

    await bloc.close();
    await reminderService.closeRecorder();
    await repository.controller.close();
  });

  test('resyncs reminders when a favorited event time changes', () async {
    final favoritesBox = await Hive.openBox<List<String>>('favorites');
    await favoritesBox.put('timetable_favorites', const ['event-1']);
    final repository = _StreamingTimetableRepository();
    final settingsBox = await Hive.openBox('settings');
    final reminderService = _RecordingEventReminderService(
      settingsBox: settingsBox,
    );
    final bloc = TimetableBloc(
      repository: repository,
      eventReminderService: reminderService,
    );
    final originalEvent = _event(
      id: 'event-1',
      title: 'Open Lab',
      startTime: DateTime(2026, 5, 20, 11),
      tags: const ['science'],
    );
    final updatedEvent = _event(
      id: 'event-1',
      title: 'Open Lab',
      startTime: DateTime(2026, 5, 20, 12, 30),
      tags: const ['science'],
    );

    final loaded = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TimetableState>().having(
          (state) => state.favoriteIds,
          'favorite ids',
          const ['event-1'],
        ),
      ),
    );

    bloc.add(const LoadTimetableEvents());
    repository.controller.add([originalEvent]);
    await loaded;

    final reminderSync = reminderService.syncs.firstWhere((call) {
      final syncedEvent = call.events.firstWhere(
        (item) => item.id == 'event-1',
        orElse: () => _event(
          id: 'missing',
          title: 'Missing',
          startTime: DateTime(2026, 1, 1),
          tags: const [],
        ),
      );
      return call.favoriteIds.contains('event-1') &&
          syncedEvent.startTime == updatedEvent.startTime;
    });

    repository.controller.add([updatedEvent]);

    final syncCall = await reminderSync;
    expect(syncCall.favoriteIds, ['event-1']);
    expect(syncCall.events.single.startTime, updatedEvent.startTime);

    await bloc.close();
    await reminderService.closeRecorder();
    await repository.controller.close();
  });

  test('syncs reminder removal when an event is unfavorited', () async {
    final favoritesBox = await Hive.openBox<List<String>>('favorites');
    await favoritesBox.put('timetable_favorites', const ['event-1']);
    final repository = _StreamingTimetableRepository();
    final settingsBox = await Hive.openBox('settings');
    final reminderService = _RecordingEventReminderService(
      settingsBox: settingsBox,
    );
    final bloc = TimetableBloc(
      repository: repository,
      eventReminderService: reminderService,
    );
    final event = _event(
      id: 'event-1',
      title: 'Open Lab',
      startTime: DateTime(2026, 5, 20, 11),
      tags: const ['science'],
    );

    final loaded = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TimetableState>().having(
          (state) => state.favoriteIds,
          'favorite ids',
          const ['event-1'],
        ),
      ),
    );

    bloc.add(const LoadTimetableEvents());
    repository.controller.add([event]);
    await loaded;

    final reminderSync = reminderService.syncs.firstWhere(
      (call) => call.favoriteIds.isEmpty,
    );
    bloc.add(const ToggleFavorite('event-1'));

    final syncCall = await reminderSync;
    expect(syncCall.favoriteIds, isEmpty);
    expect(syncCall.events.map((item) => item.id), ['event-1']);

    await bloc.close();
    await reminderService.closeRecorder();
    await repository.controller.close();
  });
}

model.TimetableEvent _event({
  required String id,
  required String title,
  required DateTime startTime,
  required List<String> tags,
}) {
  return model.TimetableEvent(
    id: id,
    title: title,
    description: 'Description',
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 1)),
    location: 'Campus',
    tags: tags,
  );
}
