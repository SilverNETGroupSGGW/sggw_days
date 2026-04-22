import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
      final articles = <WikiArticle>[];
      for (final doc in snapshot.docs) {
        try {
          final data = _normalizeWikiArticleData(doc.id, doc.data());
          articles.add(WikiArticle.fromJson(data));
        } catch (e) {
          debugPrint('Skipping wiki article ${doc.id}: $e');
        }
      }
      await _cacheData(articles.map((a) => a.toJson()).toList());
      return articles;
    } on FirebaseException {
      return await _loadFromCache();
    } catch (e) {
      debugPrint('WikiRepository error: $e');
      return await _loadFromCache();
    }
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
      final articles = <WikiArticle>[];
      for (final json in data) {
        try {
          final normalized = _normalizeWikiArticleData(
            null,
            Map<String, dynamic>.from(json as Map),
          );
          articles.add(WikiArticle.fromJson(normalized));
        } catch (e) {
          debugPrint('Skipping cached wiki article: $e');
        }
      }
      return articles;
    }
    return [];
  }

  Map<String, dynamic> _normalizeWikiArticleData(
    String? id,
    Map<String, dynamic> rawData,
  ) {
    final data = Map<String, dynamic>.from(rawData);
    if (id != null) {
      data['id'] = id;
    }

    if (!_hasRequiredText(data['title']) ||
        !_hasRequiredText(data['content']) ||
        !_hasRequiredText(data['category'])) {
      throw const FormatException('Missing required wiki article fields');
    }

    data['imageUrl'] = _toNullableString(data['imageUrl']);
    data['tags'] = _toStringList(data['tags']);
    data['treasurePointIds'] = _toStringList(data['treasurePointIds']);

    return data;
  }

  bool _hasRequiredText(Object? value) {
    return (value is String ? value : value?.toString() ?? '')
        .trim()
        .isNotEmpty;
  }

  String? _toNullableString(Object? value) {
    final text = (value is String ? value : value?.toString() ?? '').trim();
    return text.isEmpty ? null : text;
  }

  List<String> _toStringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return const [];
  }
}
