import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sggw_days/features/admin/data/models/invalid_entry.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AdminRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  // Treasure Points CRUD
  Future<TreasurePoint> createTreasurePoint(TreasurePoint point) async {
    try {
      final data = point.toJson()
        ..remove('id')
        ..remove('isFound');
      final docRef = await _firestore.collection('treasure_points').add(data);
      return point.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create treasure point: $e');
    }
  }

  Future<TreasurePoint> updateTreasurePoint(TreasurePoint point) async {
    try {
      final data = point.toJson()
        ..remove('id')
        ..remove('isFound');
      await _firestore.collection('treasure_points').doc(point.id).update(data);
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
      final docRef = await _firestore.collection('wiki_articles').add(data);
      return article.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create wiki article: $e');
    }
  }

  Future<WikiArticle> updateWikiArticle(WikiArticle article) async {
    try {
      final data = article.toJson()..remove('id');
      await _firestore.collection('wiki_articles').doc(article.id).update(data);
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
      final docRef = await _firestore.collection('timetable_events').add(data);
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

  // Image Upload
  Future<String> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    required String folder,
  }) async {
    try {
      final ref = _storage.ref().child('$folder/$fileName');
      final metadata = SettableMetadata(
        contentType: 'image/${fileName.split('.').last}',
      );
      await ref.putData(imageBytes, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Fetch & Validate (single Firestore call returns both valid and invalid)
  Future<({List<TreasurePoint> valid, List<InvalidEntry> invalid})>
  fetchAndValidateTreasurePoints() async {
    final snapshot = await _firestore.collection('treasure_points').get();
    final valid = <TreasurePoint>[];
    final invalid = <InvalidEntry>[];
    for (final doc in snapshot.docs) {
      final raw = Map<String, dynamic>.from(doc.data());
      raw['id'] = doc.id;
      try {
        final parsed = TreasurePoint.fromJson(raw);
        final roundTripped = parsed.toJson();
        final issues = _compareJson(
          raw,
          roundTripped,
          excludeKeys: {'isFound'},
        );
        if (issues.isNotEmpty) {
          invalid.add(
            InvalidEntry(
              id: doc.id,
              collection: 'treasure_points',
              rawData: raw,
              issues: issues,
              fixedData: roundTripped..remove('isFound'),
            ),
          );
        }
        valid.add(parsed);
      } catch (e) {
        invalid.add(
          InvalidEntry(
            id: doc.id,
            collection: 'treasure_points',
            rawData: raw,
            issues: ['Parse error: $e'],
          ),
        );
      }
    }
    return (valid: valid, invalid: invalid);
  }

  Future<({List<WikiArticle> valid, List<InvalidEntry> invalid})>
  fetchAndValidateWikiArticles() async {
    final snapshot = await _firestore.collection('wiki_articles').get();
    final valid = <WikiArticle>[];
    final invalid = <InvalidEntry>[];
    for (final doc in snapshot.docs) {
      final raw = Map<String, dynamic>.from(doc.data());
      raw['id'] = doc.id;
      try {
        final parsed = WikiArticle.fromJson(raw);
        final roundTripped = parsed.toJson();
        final issues = _compareJson(raw, roundTripped);
        if (issues.isNotEmpty) {
          invalid.add(
            InvalidEntry(
              id: doc.id,
              collection: 'wiki_articles',
              rawData: raw,
              issues: issues,
              fixedData: roundTripped,
            ),
          );
        }
        valid.add(parsed);
      } catch (e) {
        invalid.add(
          InvalidEntry(
            id: doc.id,
            collection: 'wiki_articles',
            rawData: raw,
            issues: ['Parse error: $e'],
          ),
        );
      }
    }
    return (valid: valid, invalid: invalid);
  }

  Future<({List<TimetableEvent> valid, List<InvalidEntry> invalid})>
  fetchAndValidateTimetableEvents() async {
    final snapshot = await _firestore.collection('timetable_events').get();
    final valid = <TimetableEvent>[];
    final invalid = <InvalidEntry>[];
    for (final doc in snapshot.docs) {
      final raw = Map<String, dynamic>.from(doc.data());
      raw['id'] = doc.id;
      if (raw['startTime'] is Timestamp) {
        raw['startTime'] = (raw['startTime'] as Timestamp)
            .toDate()
            .toIso8601String();
      }
      if (raw['endTime'] is Timestamp) {
        raw['endTime'] = (raw['endTime'] as Timestamp)
            .toDate()
            .toIso8601String();
      }
      try {
        final parsed = TimetableEvent.fromJson(raw);
        final roundTripped = parsed.toJson();
        final issues = _compareJson(raw, roundTripped);
        if (issues.isNotEmpty) {
          invalid.add(
            InvalidEntry(
              id: doc.id,
              collection: 'timetable_events',
              rawData: raw,
              issues: issues,
              fixedData: roundTripped,
            ),
          );
        }
        valid.add(parsed);
      } catch (e) {
        invalid.add(
          InvalidEntry(
            id: doc.id,
            collection: 'timetable_events',
            rawData: raw,
            issues: ['Parse error: $e'],
          ),
        );
      }
    }
    return (valid: valid, invalid: invalid);
  }

  Future<void> fixInvalidEntry(
    String collection,
    String docId,
    Map<String, dynamic> fixedData,
  ) async {
    final data = Map<String, dynamic>.from(fixedData)..remove('id');
    await _firestore.collection(collection).doc(docId).set(data);
  }

  List<String> _compareJson(
    Map<String, dynamic> raw,
    Map<String, dynamic> fixed, {
    Set<String> excludeKeys = const {},
  }) {
    final issues = <String>[];
    final allKeys = {...raw.keys, ...fixed.keys}
      ..remove('id')
      ..removeAll(excludeKeys);
    for (final key in allKeys) {
      if (!raw.containsKey(key)) {
        issues.add('Missing field: $key');
      } else if (!fixed.containsKey(key)) {
        issues.add('Unknown field: $key');
      } else if ('${raw[key]}' != '${fixed[key]}') {
        issues.add("Field '$key': '${raw[key]}' → '${fixed[key]}'");
      }
    }
    return issues;
  }
}
