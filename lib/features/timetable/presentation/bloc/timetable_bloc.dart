import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart'
    as model;
import 'package:sggw_days/features/timetable/data/repositories/timetable_repository.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository _repository;

  TimetableBloc({required TimetableRepository repository})
    : _repository = repository,
      super(TimetableState(selectedDate: DateTime.now())) {
    on<LoadTimetableEvents>(_onLoadTimetableEvents);
    on<FilterEventsByDate>(_onFilterEventsByDate);
    on<FilterEventsByTag>(_onFilterEventsByTag);
    on<ToggleFavorite>(_onToggleFavorite);
    on<ToggleShowFavorites>(_onToggleShowFavorites);
    on<CheckInEvent>(_onCheckInEvent);
  }

  Future<void> _onLoadTimetableEvents(
    LoadTimetableEvents event,
    Emitter<TimetableState> emit,
  ) async {
    emit(state.copyWith(status: TimetableStatus.loading));
    try {
      final events = await _repository.getEvents();

      // Load favorites from Hive
      final favBox = await Hive.openBox<List<String>>('favorites');
      final favoriteIds = favBox.get('timetable_favorites', defaultValue: <String>[]) ?? <String>[];

      // Load check-ins from Hive
      final checkInBox = await Hive.openBox<List<String>>('check_ins');
      final checkedInIds = checkInBox.get('event_check_ins', defaultValue: <String>[]) ?? <String>[];

      final filtered = _filterEvents(
        events,
        state.selectedDate,
        state.selectedTag,
        favoriteIds,
        state.showFavoritesOnly,
      );

      emit(
        state.copyWith(
          status: TimetableStatus.success,
          events: events,
          filteredEvents: filtered,
          selectedTag: state.selectedTag,
          favoriteIds: favoriteIds,
          checkedInIds: checkedInIds,
        ),
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

  void _onFilterEventsByDate(
    FilterEventsByDate event,
    Emitter<TimetableState> emit,
  ) {
    final filtered = _filterEvents(
      state.events, event.date, state.selectedTag,
      state.favoriteIds, state.showFavoritesOnly,
    );
    emit(state.copyWith(filteredEvents: filtered, selectedDate: event.date));
  }

  void _onFilterEventsByTag(
    FilterEventsByTag event,
    Emitter<TimetableState> emit,
  ) {
    final filtered = _filterEvents(
      state.events, state.selectedDate, event.tag,
      state.favoriteIds, state.showFavoritesOnly,
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
      state.events, state.selectedDate, state.selectedTag,
      updatedFavorites, state.showFavoritesOnly,
    );

    emit(state.copyWith(
      favoriteIds: updatedFavorites,
      filteredEvents: filtered,
    ));
  }

  void _onToggleShowFavorites(
    ToggleShowFavorites event,
    Emitter<TimetableState> emit,
  ) {
    final newShowFavorites = !state.showFavoritesOnly;
    final filtered = _filterEvents(
      state.events, state.selectedDate, state.selectedTag,
      state.favoriteIds, newShowFavorites,
    );
    emit(state.copyWith(
      showFavoritesOnly: newShowFavorites,
      filteredEvents: filtered,
    ));
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
      filtered = filtered.where((event) => favoriteIds.contains(event.id)).toList();
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
}
