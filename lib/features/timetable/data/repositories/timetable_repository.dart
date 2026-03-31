import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/core/config/api_config.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';

class TimetableRepository {
  final Dio _dio;
  final String _baseUrl;
  static const _cacheKey = 'timetable_events_cache';

  TimetableRepository({Dio? dio, String? baseUrl})
    : _dio = dio ?? Dio(),
      _baseUrl = baseUrl ?? ApiConfig.defaultBaseUrl;

  Future<List<TimetableEvent>> getEvents() async {
    try {
      final response = await _dio.get('$_baseUrl/timetable_events');
      final List<dynamic> data = response.data as List<dynamic>;
      final events = data
          .map((json) => TimetableEvent.fromJson(json as Map<String, dynamic>))
          .toList();
      await _cacheData(data);
      return events;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      return await _loadFromCache();
    } catch (e) {
      return await _loadFromCache();
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

  Future<void> _cacheData(List<dynamic> data) async {
    final box = await Hive.openBox('api_cache');
    await box.put(_cacheKey, jsonEncode(data));
  }

  Future<List<TimetableEvent>> _loadFromCache() async {
    final box = await Hive.openBox('api_cache');
    final cached = box.get(_cacheKey) as String?;
    if (cached != null) {
      final List<dynamic> data = jsonDecode(cached) as List<dynamic>;
      return data
          .map((json) => TimetableEvent.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
