import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';

class WikiRepository {
  final FirebaseFirestore _firestore;
  static const _cacheKey = 'wiki_articles_cache';

  WikiRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<WikiArticle>> getArticles() async {
    try {
      final snapshot = await _firestore.collection('wiki_articles').get();
      final articles = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WikiArticle.fromJson(data);
      }).toList();
      await _cacheData(articles.map((a) => a.toJson()).toList());
      return articles;
    } on FirebaseException {
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

  Future<void> _cacheData(List<Map<String, dynamic>> data) async {
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
