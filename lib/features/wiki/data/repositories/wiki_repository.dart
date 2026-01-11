import 'package:dio/dio.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';

class WikiRepository {
  final Dio _dio;
  final String _baseUrl;

  WikiRepository({
    Dio? dio,
    String baseUrl = 'https://raw.githubusercontent.com/sggw-days/api/main',
  }) : _dio = dio ?? Dio(),
       _baseUrl = baseUrl;

  Future<List<WikiArticle>> getArticles() async {
    try {
      final response = await _dio.get('$_baseUrl/wiki_articles.json');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => WikiArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load wiki articles: $e');
    }
  }

  Future<WikiArticle> getArticleById(String id) async {
    final articles = await getArticles();
    return articles.firstWhere(
      (article) => article.id == id,
      orElse: () => throw Exception('Article not found'),
    );
  }
}
