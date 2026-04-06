import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Treasure Points CRUD
  Future<TreasurePoint> createTreasurePoint(TreasurePoint point) async {
    try {
      final data = point.toJson()..remove('id')..remove('isFound');
      final docRef =
          await _firestore.collection('treasure_points').add(data);
      return point.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create treasure point: $e');
    }
  }

  Future<TreasurePoint> updateTreasurePoint(TreasurePoint point) async {
    try {
      final data = point.toJson()..remove('id')..remove('isFound');
      await _firestore
          .collection('treasure_points')
          .doc(point.id)
          .update(data);
      return point;
    } catch (e) {
      throw Exception('Failed to update treasure point: $e');
    }
  }

  Future<void> deleteTreasurePoint(String id) async {
    try {
      await _firestore.collection('treasure_points').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete treasure point: $e');
    }
  }

  // Wiki Articles CRUD
  Future<WikiArticle> createWikiArticle(WikiArticle article) async {
    try {
      final data = article.toJson()..remove('id');
      final docRef =
          await _firestore.collection('wiki_articles').add(data);
      return article.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create wiki article: $e');
    }
  }

  Future<WikiArticle> updateWikiArticle(WikiArticle article) async {
    try {
      final data = article.toJson()..remove('id');
      await _firestore
          .collection('wiki_articles')
          .doc(article.id)
          .update(data);
      return article;
    } catch (e) {
      throw Exception('Failed to update wiki article: $e');
    }
  }

  Future<void> deleteWikiArticle(String id) async {
    try {
      await _firestore.collection('wiki_articles').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete wiki article: $e');
    }
  }

  // Timetable Events CRUD
  Future<TimetableEvent> createTimetableEvent(TimetableEvent event) async {
    try {
      final data = event.toJson()..remove('id');
      final docRef =
          await _firestore.collection('timetable_events').add(data);
      return event.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create timetable event: $e');
    }
  }

  Future<TimetableEvent> updateTimetableEvent(TimetableEvent event) async {
    try {
      final data = event.toJson()..remove('id');
      await _firestore
          .collection('timetable_events')
          .doc(event.id)
          .update(data);
      return event;
    } catch (e) {
      throw Exception('Failed to update timetable event: $e');
    }
  }

  Future<void> deleteTimetableEvent(String id) async {
    try {
      await _firestore.collection('timetable_events').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete timetable event: $e');
    }
  }
}
