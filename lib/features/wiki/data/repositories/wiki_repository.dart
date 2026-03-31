import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/core/config/api_config.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';

class WikiRepository {
  final Dio _dio;
  final String _baseUrl;
  static const _cacheKey = 'wiki_articles_cache';

  WikiRepository({Dio? dio, String? baseUrl})
    : _dio = dio ?? Dio(),
      _baseUrl = baseUrl ?? ApiConfig.defaultBaseUrl;

  Future<List<WikiArticle>> getArticles() async {
    try {
      final response = await _dio.get('$_baseUrl/wiki_articles');
      final List<dynamic> data = response.data as List<dynamic>;
      final articles = data
          .map((json) => WikiArticle.fromJson(json as Map<String, dynamic>))
          .toList();
      await _cacheData(data);
      return articles;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      return await _loadFromCache();
    } catch (e) {
      return await _loadFromCache();
    }
  }

  Future<WikiArticle> getArticleById(String id) async {
    final articles = await getArticles();
    return articles.firstWhere(
      (article) => article.id == id,
      orElse: () => throw Exception('Article not found'),
    );
  }

  Future<void> _cacheData(List<dynamic> data) async {
    final box = await Hive.openBox('api_cache');
    await box.put(_cacheKey, jsonEncode(data));
  }

  Future<List<WikiArticle>> _loadFromCache() async {
    final box = await Hive.openBox('api_cache');
    final cached = box.get(_cacheKey) as String?;
    if (cached != null) {
      final List<dynamic> data = jsonDecode(cached) as List<dynamic>;
      return data
          .map((json) => WikiArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
