import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/features/timetable/data/repositories/timetable_repository.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_state.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart' as model;

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository _repository;

  TimetableBloc({required TimetableRepository repository})
      : _repository = repository,
        super(TimetableState(selectedDate: DateTime.now())) {
    on<LoadTimetableEvents>(_onLoadTimetableEvents);
    on<FilterEventsByDate>(_onFilterEventsByDate);
    on<FilterEventsByTag>(_onFilterEventsByTag);
  }

  Future<void> _onLoadTimetableEvents(
    LoadTimetableEvents event,
    Emitter<TimetableState> emit,
  ) async {
    emit(state.copyWith(status: TimetableStatus.loading));
    try {
      final events = await _repository.getEvents();
      final filtered = _filterEvents(events, state.selectedDate, state.selectedTag);
      
      emit(state.copyWith(
        status: TimetableStatus.success,
        events: events,
        filteredEvents: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TimetableStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onFilterEventsByDate(
    FilterEventsByDate event,
    Emitter<TimetableState> emit,
  ) {
    final filtered = _filterEvents(state.events, event.date, state.selectedTag);
    emit(state.copyWith(
      filteredEvents: filtered,
      selectedDate: event.date,
    ));
  }

  void _onFilterEventsByTag(
    FilterEventsByTag event,
    Emitter<TimetableState> emit,
  ) {
    final filtered = _filterEvents(state.events, state.selectedDate, event.tag);
    emit(state.copyWith(
      filteredEvents: filtered,
      selectedTag: event.tag,
    ));
  }

  List<model.TimetableEvent> _filterEvents(
    List<model.TimetableEvent> events,
    DateTime? date,
    String? tag,
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

    return filtered;
  }
}
