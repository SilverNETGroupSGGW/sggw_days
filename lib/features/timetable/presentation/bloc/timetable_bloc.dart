import 'dart:async';

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
      final (:favoriteIds, :checkedInIds) = await _loadLocalSelections();

      emit(
        state.copyWith(
          selectedTag: state.selectedTag,
          favoriteIds: favoriteIds,
          checkedInIds: checkedInIds,
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

  Future<({List<String> favoriteIds, List<String> checkedInIds})>
  _loadLocalSelections() async {
    final favBox = await Hive.openBox<List<String>>('favorites');
    final favoriteIds =
        favBox.get('timetable_favorites', defaultValue: <String>[]) ??
        <String>[];

    final checkInBox = await Hive.openBox<List<String>>('check_ins');
    final checkedInIds =
        checkInBox.get('event_check_ins', defaultValue: <String>[]) ??
        <String>[];

    return (favoriteIds: favoriteIds, checkedInIds: checkedInIds);
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

    final favBox = await Hive.openBox<List<String>>('favorites');
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
    await _syncEventReminders(state.events, updatedFavorites);
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

  Future<void> _syncEventReminders(
    List<model.TimetableEvent> events,
    List<String> favoriteIds,
  ) async {
    try {
      await _eventReminderService?.scheduleFavoriteEventReminders(
        events,
        favoriteIds,
      );
    } catch (_) {}
  }

  void _onTimetableEventsUpdated(
    _TimetableEventsUpdated event,
    Emitter<TimetableState> emit,
  ) {
    final selectedDate = state.selectedDate ?? _firstEventDate(event.events);
    final filtered = _filterEvents(
      event.events,
      selectedDate,
      state.selectedTag,
      state.favoriteIds,
      state.showFavoritesOnly,
    );

    emit(
      state.copyWith(
        status: TimetableStatus.success,
        events: event.events,
        filteredEvents: filtered,
        selectedDate: selectedDate,
        errorMessage: null,
      ),
    );
    unawaited(_syncEventReminders(event.events, state.favoriteIds));
  }

  DateTime? _firstEventDate(List<model.TimetableEvent> events) {
    if (events.isEmpty) return null;
    final sorted = List<model.TimetableEvent>.from(events)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final first = sorted.first.startTime;
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

    return filtered;
  }

  Future<void> _onCheckInEvent(
    CheckInEvent event,
    Emitter<TimetableState> emit,
  ) async {
    final updatedCheckIns = List<String>.from(state.checkedInIds);
    if (!updatedCheckIns.contains(event.eventId)) {
      updatedCheckIns.add(event.eventId);

      final checkInBox = await Hive.openBox<List<String>>('check_ins');
      await checkInBox.put('event_check_ins', updatedCheckIns);

      emit(state.copyWith(checkedInIds: updatedCheckIns));
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
