import 'package:dio/dio.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';

class TimetableRepository {
  final Dio _dio;
  final String _baseUrl;

  TimetableRepository({
    Dio? dio,
    String baseUrl = 'https://raw.githubusercontent.com/sggw-days/api/main',
  }) : _dio = dio ?? Dio(),
       _baseUrl = baseUrl;

  Future<List<TimetableEvent>> getEvents() async {
    try {
      final response = await _dio.get('$_baseUrl/timetable_events.json');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => TimetableEvent.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load timetable events: $e');
    }
  }

  Future<List<TimetableEvent>> getEventsByDate(DateTime date) async {
    final events = await getEvents();
    return events.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList();
  }
}
