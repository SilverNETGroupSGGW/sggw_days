import 'package:freezed_annotation/freezed_annotation.dart';

part 'timetable_event.freezed.dart';
part 'timetable_event.g.dart';

@freezed
abstract class TimetableEvent with _$TimetableEvent {
  const factory TimetableEvent({
    required String id,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    String? imageUrl,
    @Default([]) List<String> tags,
    @Default([]) List<String> treasurePointIds,
  }) = _TimetableEvent;

  factory TimetableEvent.fromJson(Map<String, dynamic> json) =>
      _$TimetableEventFromJson(json);
}
