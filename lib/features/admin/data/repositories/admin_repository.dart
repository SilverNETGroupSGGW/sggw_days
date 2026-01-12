import 'package:dio/dio.dart';
import 'package:sggw_days/core/config/api_config.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';

class AdminRepository {
  final Dio _dio;
  final String _baseUrl;

  AdminRepository({Dio? dio, String? baseUrl})
    : _dio = dio ?? Dio(),
      _baseUrl = baseUrl ?? ApiConfig.defaultBaseUrl;

  // Treasure Points CRUD
  Future<TreasurePoint> createTreasurePoint(TreasurePoint point) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/treasure_points',
        data: point.toJson(),
      );
      return TreasurePoint.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create treasure point: $e');
    }
  }

  Future<TreasurePoint> updateTreasurePoint(TreasurePoint point) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/treasure_points/${point.id}',
        data: point.toJson(),
      );
      return TreasurePoint.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update treasure point: $e');
    }
  }

  Future<void> deleteTreasurePoint(String id) async {
    try {
      await _dio.delete('$_baseUrl/treasure_points/$id');
    } catch (e) {
      throw Exception('Failed to delete treasure point: $e');
    }
  }

  // Wiki Articles CRUD
  Future<WikiArticle> createWikiArticle(WikiArticle article) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/wiki_articles',
        data: article.toJson(),
      );
      return WikiArticle.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create wiki article: $e');
    }
  }

  Future<WikiArticle> updateWikiArticle(WikiArticle article) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/wiki_articles/${article.id}',
        data: article.toJson(),
      );
      return WikiArticle.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update wiki article: $e');
    }
  }

  Future<void> deleteWikiArticle(String id) async {
    try {
      await _dio.delete('$_baseUrl/wiki_articles/$id');
    } catch (e) {
      throw Exception('Failed to delete wiki article: $e');
    }
  }

  // Timetable Events CRUD
  Future<TimetableEvent> createTimetableEvent(TimetableEvent event) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/timetable_events',
        data: event.toJson(),
      );
      return TimetableEvent.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create timetable event: $e');
    }
  }

  Future<TimetableEvent> updateTimetableEvent(TimetableEvent event) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/timetable_events/${event.id}',
        data: event.toJson(),
      );
      return TimetableEvent.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update timetable event: $e');
    }
  }

  Future<void> deleteTimetableEvent(String id) async {
    try {
      await _dio.delete('$_baseUrl/timetable_events/$id');
    } catch (e) {
      throw Exception('Failed to delete timetable event: $e');
    }
  }
}
