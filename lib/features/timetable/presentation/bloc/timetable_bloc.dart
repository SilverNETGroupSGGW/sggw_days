import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/notifications/data/event_reminder_service.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart'
    as model;
import 'package:sggw_days/features/timetable/data/repositories/timetable_repository.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository _repository;
  final EventReminderService? _eventReminderService;
  StreamSubscription<List<model.TimetableEvent>>? _eventsSubscription;
  Future<Box<List<String>>>? _favoritesBoxFuture;
  Future<Box<List<String>>>? _checkInBoxFuture;
  Future<Box<dynamic>>? _checkInHistoryBoxFuture;
  Future<void> _reminderSyncQueue = Future<void>.value();

  TimetableBloc({
    required TimetableRepository repository,
    EventReminderService? eventReminderService,
  }) : _repository = repository,
       _eventReminderService = eventReminderService,
       super(const TimetableState()) {
    on<LoadTimetableEvents>(_onLoadTimetableEvents);
    on<FilterEventsByDate>(_onFilterEventsByDate);
    on<FilterEventsByTag>(_onFilterEventsByTag);
    on<ToggleFavorite>(_onToggleFavorite);
    on<ToggleShowFavorites>(_onToggleShowFavorites);
    on<CheckInEvent>(_onCheckInEvent);
    on<_TimetableEventsUpdated>(_onTimetableEventsUpdated);
    on<_TimetableEventsFailed>(_onTimetableEventsFailed);
  }

  Future<void> _onLoadTimetableEvents(
    LoadTimetableEvents event,
    Emitter<TimetableState> emit,
  ) async {
    emit(state.copyWith(status: TimetableStatus.loading));
    try {
      await _eventsSubscription?.cancel();
      final (:favoriteIds, :checkedInIds, :checkedInHistory) =
          await _loadLocalSelections();

      emit(
        state.copyWith(
          selectedTag: state.selectedTag,
          favoriteIds: favoriteIds,
          checkedInIds: checkedInIds,
          checkedInHistory: checkedInHistory,
        ),
      );

      _eventsSubscription = _repository.watchEvents().listen(
        (events) => add(_TimetableEventsUpdated(events)),
        onError: (Object error) =>
            add(_TimetableEventsFailed(error.toString())),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TimetableStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<
    ({
      List<String> favoriteIds,
      List<String> checkedInIds,
      Map<String, DateTime> checkedInHistory,
    })
  >
  _loadLocalSelections() async {
    final favBox = await _favoritesBox();
    final favoriteIds =
        favBox.get('timetable_favorites', defaultValue: <String>[]) ??
        <String>[];

    final checkInBox = await _checkInBox();
    final checkedInIds =
        checkInBox.get('event_check_ins', defaultValue: <String>[]) ??
        <String>[];

    final historyBox = await _checkInHistoryBox();
    final checkedInHistory = <String, DateTime>{};
    for (final key in historyBox.keys) {
      final value = historyBox.get(key);
      if (key is String && value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) checkedInHistory[key] = parsed;
      }
    }

    final migratedAt = DateTime.now();
    for (final id in checkedInIds) {
      if (!checkedInHistory.containsKey(id)) {
        checkedInHistory[id] = migratedAt;
        await historyBox.put(id, migratedAt.toIso8601String());
      }
    }

    return (
      favoriteIds: favoriteIds,
      checkedInIds: checkedInIds,
      checkedInHistory: checkedInHistory,
    );
  }

  void _onFilterEventsByDate(
    FilterEventsByDate event,
    Emitter<TimetableState> emit,
  ) {
    final filtered = _filterEvents(
      state.events,
      event.date,
      state.selectedTag,
      state.favoriteIds,
      state.showFavoritesOnly,
    );
    emit(state.copyWith(filteredEvents: filtered, selectedDate: event.date));
  }

  void _onFilterEventsByTag(
    FilterEventsByTag event,
    Emitter<TimetableState> emit,
  ) {
    final filtered = _filterEvents(
      state.events,
      state.selectedDate,
      event.tag,
      state.favoriteIds,
      state.showFavoritesOnly,
    );
    emit(state.copyWith(filteredEvents: filtered, selectedTag: event.tag));
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<TimetableState> emit,
  ) async {
    final updatedFavorites = List<String>.from(state.favoriteIds);
    if (updatedFavorites.contains(event.eventId)) {
      updatedFavorites.remove(event.eventId);
    } else {
      updatedFavorites.add(event.eventId);
    }

    final favBox = await _favoritesBox();
    await favBox.put('timetable_favorites', updatedFavorites);

    final filtered = _filterEvents(
      state.events,
      state.selectedDate,
      state.selectedTag,
      updatedFavorites,
      state.showFavoritesOnly,
    );

    emit(
      state.copyWith(favoriteIds: updatedFavorites, filteredEvents: filtered),
    );
    unawaited(_queueReminderSync());
  }

  void _onToggleShowFavorites(
    ToggleShowFavorites event,
    Emitter<TimetableState> emit,
  ) {
    final newShowFavorites = !state.showFavoritesOnly;
    final filtered = _filterEvents(
      state.events,
      state.selectedDate,
      state.selectedTag,
      state.favoriteIds,
      newShowFavorites,
    );
    emit(
      state.copyWith(
        showFavoritesOnly: newShowFavorites,
        filteredEvents: filtered,
      ),
    );
  }

  Future<Box<List<String>>> _favoritesBox() {
    return _favoritesBoxFuture ??= Hive.openBox<List<String>>('favorites');
  }

  Future<Box<List<String>>> _checkInBox() {
    return _checkInBoxFuture ??= Hive.openBox<List<String>>('check_ins');
  }

  Future<Box<dynamic>> _checkInHistoryBox() {
    return _checkInHistoryBoxFuture ??= Hive.openBox('event_check_in_history');
  }

  Future<void> _queueReminderSync() async {
    final reminderService = _eventReminderService;
    if (reminderService == null) return;

    try {
      await (_reminderSyncQueue = _reminderSyncQueue.catchError((_) {}).then((
        _,
      ) async {
        final currentState = state;
        await reminderService.scheduleFavoriteEventReminders(
          currentState.events,
          currentState.favoriteIds,
        );
      }));
    } catch (error) {
      debugPrint('Failed to sync event reminders: $error');
    }
  }

  void _onTimetableEventsUpdated(
    _TimetableEventsUpdated event,
    Emitter<TimetableState> emit,
  ) {
    final sortedEvents = _sortEvents(event.events);
    final selectedDate = state.selectedDate ?? _firstEventDate(sortedEvents);
    final filtered = _filterEvents(
      sortedEvents,
      selectedDate,
      state.selectedTag,
      state.favoriteIds,
      state.showFavoritesOnly,
    );

    emit(
      state.copyWith(
        status: TimetableStatus.success,
        events: sortedEvents,
        filteredEvents: filtered,
        selectedDate: selectedDate,
        errorMessage: null,
      ),
    );
    unawaited(_queueReminderSync());
  }

  DateTime? _firstEventDate(List<model.TimetableEvent> events) {
    if (events.isEmpty) return null;
    final first = _sortEvents(events).first.startTime;
    return DateTime(first.year, first.month, first.day);
  }

  void _onTimetableEventsFailed(
    _TimetableEventsFailed event,
    Emitter<TimetableState> emit,
  ) {
    emit(
      state.copyWith(
        status: state.events.isEmpty
            ? TimetableStatus.error
            : TimetableStatus.success,
        errorMessage: event.message,
      ),
    );
  }

  List<model.TimetableEvent> _filterEvents(
    List<model.TimetableEvent> events,
    DateTime? date,
    String? tag,
    List<String> favoriteIds,
    bool showFavoritesOnly,
  ) {
    var filtered = events;

    if (date != null) {
      filtered = filtered.where((event) {
        return event.startTime.year == date.year &&
            event.startTime.month == date.month &&
            event.startTime.day == date.day;
      }).toList();
    }

    if (tag != null) {
      filtered = filtered.where((event) => event.tags.contains(tag)).toList();
    }

    if (showFavoritesOnly) {
      filtered = filtered
          .where((event) => favoriteIds.contains(event.id))
          .toList();
    }

    return _sortEvents(filtered);
  }

  List<model.TimetableEvent> _sortEvents(
    Iterable<model.TimetableEvent> events,
  ) {
    return List<model.TimetableEvent>.from(events)..sort(_compareEvents);
  }

  int _compareEvents(model.TimetableEvent a, model.TimetableEvent b) {
    final start = a.startTime.compareTo(b.startTime);
    if (start != 0) return start;

    final end = a.endTime.compareTo(b.endTime);
    if (end != 0) return end;

    final title = a.title.compareTo(b.title);
    if (title != 0) return title;

    return a.id.compareTo(b.id);
  }

  Future<void> _onCheckInEvent(
    CheckInEvent event,
    Emitter<TimetableState> emit,
  ) async {
    final updatedCheckIns = List<String>.from(state.checkedInIds);
    final updatedHistory = Map<String, DateTime>.from(state.checkedInHistory);
    if (!updatedCheckIns.contains(event.eventId)) {
      updatedCheckIns.add(event.eventId);
      final checkedInAt = DateTime.now();
      updatedHistory[event.eventId] = checkedInAt;

      final checkInBox = await _checkInBox();
      await checkInBox.put('event_check_ins', updatedCheckIns);
      final historyBox = await _checkInHistoryBox();
      await historyBox.put(event.eventId, checkedInAt.toIso8601String());

      emit(
        state.copyWith(
          checkedInIds: updatedCheckIns,
          checkedInHistory: updatedHistory,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _eventsSubscription?.cancel();
    return super.close();
  }
}

class _TimetableEventsUpdated extends TimetableEvent {
  final List<model.TimetableEvent> events;

  const _TimetableEventsUpdated(this.events);

  @override
  List<Object?> get props => [events];
}

class _TimetableEventsFailed extends TimetableEvent {
  final String message;

  const _TimetableEventsFailed(this.message);

  @override
  List<Object?> get props => [message];
}
