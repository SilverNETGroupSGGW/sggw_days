import 'package:equatable/equatable.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart'
    as model;

enum TimetableStatus { initial, loading, success, error }

class TimetableState extends Equatable {
  final TimetableStatus status;
  final List<model.TimetableEvent> events;
  final List<model.TimetableEvent> filteredEvents;
  final DateTime? selectedDate;
  final String? selectedTag;
  final List<String> favoriteIds;
  final bool showFavoritesOnly;
  final List<String> checkedInIds;
  final Map<String, DateTime> checkedInHistory;
  final String? errorMessage;

  const TimetableState({
    this.status = TimetableStatus.initial,
    this.events = const [],
    this.filteredEvents = const [],
    this.selectedDate,
    this.selectedTag,
    this.favoriteIds = const [],
    this.showFavoritesOnly = false,
    this.checkedInIds = const [],
    this.checkedInHistory = const {},
    this.errorMessage,
  });

  TimetableState copyWith({
    TimetableStatus? status,
    List<model.TimetableEvent>? events,
    List<model.TimetableEvent>? filteredEvents,
    DateTime? selectedDate,
    Object? selectedTag = _noChange,
    List<String>? favoriteIds,
    bool? showFavoritesOnly,
    List<String>? checkedInIds,
    Map<String, DateTime>? checkedInHistory,
    Object? errorMessage = _noChange,
  }) {
    return TimetableState(
      status: status ?? this.status,
      events: events ?? this.events,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTag: identical(selectedTag, _noChange)
          ? this.selectedTag
          : selectedTag as String?,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
      checkedInIds: checkedInIds ?? this.checkedInIds,
      checkedInHistory: checkedInHistory ?? this.checkedInHistory,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _noChange = Object();

  @override
  List<Object?> get props => [
    status,
    events,
    filteredEvents,
    selectedDate,
    selectedTag,
    favoriteIds,
    showFavoritesOnly,
    checkedInIds,
    checkedInHistory,
    errorMessage,
  ];
}
