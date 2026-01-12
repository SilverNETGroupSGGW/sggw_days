import 'package:dio/dio.dart';
import 'package:sggw_days/core/config/api_config.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

class TreasureHuntRepository {
  final Dio _dio;
  final String _baseUrl;

  TreasureHuntRepository({Dio? dio, String? baseUrl})
    : _dio = dio ?? Dio(),
      _baseUrl = baseUrl ?? ApiConfig.defaultBaseUrl;

  Future<List<TreasurePoint>> getTreasurePoints() async {
    try {
      final response = await _dio.get('$_baseUrl/treasure_points.json');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => TreasurePoint.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception('Failed to load treasure points: $e');
    } catch (e) {
      throw Exception('Failed to load treasure points: $e');
    }
  }
}
