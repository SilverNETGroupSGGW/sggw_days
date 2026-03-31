import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/core/config/api_config.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

class TreasureHuntRepository {
  final Dio _dio;
  final String _baseUrl;
  static const _cacheKey = 'treasure_points_cache';

  TreasureHuntRepository({Dio? dio, String? baseUrl})
    : _dio = dio ?? Dio(),
      _baseUrl = baseUrl ?? ApiConfig.defaultBaseUrl;

  Future<List<TreasurePoint>> getTreasurePoints() async {
    try {
      final response = await _dio.get('$_baseUrl/treasure_points');
      final List<dynamic> data = response.data as List<dynamic>;
      final points = data
          .map((json) => TreasurePoint.fromJson(json as Map<String, dynamic>))
          .toList();
      await _cacheData(data);
      return points;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      return await _loadFromCache();
    } catch (e) {
      return await _loadFromCache();
    }
  }

  Future<void> _cacheData(List<dynamic> data) async {
    final box = await Hive.openBox('api_cache');
    await box.put(_cacheKey, jsonEncode(data));
  }

  Future<List<TreasurePoint>> _loadFromCache() async {
    final box = await Hive.openBox('api_cache');
    final cached = box.get(_cacheKey) as String?;
    if (cached != null) {
      final List<dynamic> data = jsonDecode(cached) as List<dynamic>;
      return data
          .map((json) => TreasurePoint.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
