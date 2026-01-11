import 'package:equatable/equatable.dart';

abstract class TimetableEvent extends Equatable {
  const TimetableEvent();

  @override
  List<Object?> get props => [];
}

class LoadTimetableEvents extends TimetableEvent {
  const LoadTimetableEvents();
}

class FilterEventsByDate extends TimetableEvent {
  final DateTime date;

  const FilterEventsByDate(this.date);

  @override
  List<Object?> get props => [date];
}

class FilterEventsByTag extends TimetableEvent {
  final String? tag;

  const FilterEventsByTag(this.tag);

  @override
  List<Object?> get props => [tag];
}
