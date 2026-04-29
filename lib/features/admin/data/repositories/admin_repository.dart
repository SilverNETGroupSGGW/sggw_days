import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sggw_days/features/admin/data/models/invalid_entry.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/wiki/data/models/wiki_article.dart';

class AdminRepository {
  static const double _defaultCampusLatitude = 52.163017;
  static const double _defaultCampusLongitude = 21.047111;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  AdminRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance;

  // Treasure Points CRUD
  Future<TreasurePoint> createTreasurePoint(TreasurePoint point) async {
    try {
      final data = point.toJson()..remove('id');
      final docRef = await _firestore.collection('treasure_points').add(data);
      return point.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create treasure point: $e');
    }
  }

  Future<TreasurePoint> updateTreasurePoint(TreasurePoint point) async {
    try {
      final data = point.toJson()..remove('id');
      await _firestore.collection('treasure_points').doc(point.id).set(data);
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
      await _firestore.collection('wiki_articles').doc(article.id).set(data);
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
      await _firestore.collection('timetable_events').doc(event.id).set(data);
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

  Future<void> createNotificationBroadcast({
    required String title,
    required String body,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedBody = body.trim();
    if (trimmedTitle.isEmpty || trimmedBody.isEmpty) {
      throw Exception('Notification title and body are required.');
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Admin sign-in is required to send notifications.');
    }

    await _firestore.collection('notification_broadcasts').add({
      'title': trimmedTitle,
      'body': trimmedBody,
      'status': 'queued',
      'createdBy': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
        final fixedData = _sanitizeTreasurePointData(raw, parsed);
        final issues = _compareJson(raw, fixedData);
        if (issues.isNotEmpty) {
          invalid.add(
            InvalidEntry(
              id: doc.id,
              collection: 'treasure_points',
              rawData: raw,
              issues: issues,
              fixedData: fixedData,
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
      final fixedData = _trySanitizeWikiArticleData(raw);
      try {
        final parsed = WikiArticle.fromJson(raw);
        final issues = fixedData == null
            ? <String>[]
            : _compareJson(raw, fixedData);
        if (issues.isNotEmpty) {
          invalid.add(
            InvalidEntry(
              id: doc.id,
              collection: 'wiki_articles',
              rawData: raw,
              issues: issues,
              fixedData: fixedData,
            ),
          );
        }
        valid.add(parsed);
      } catch (e) {
        final issues = <String>['Parse error: $e'];
        if (fixedData != null) {
          issues.addAll(_compareJson(raw, fixedData));
        }
        invalid.add(
          InvalidEntry(
            id: doc.id,
            collection: 'wiki_articles',
            rawData: raw,
            issues: issues,
            fixedData: fixedData,
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
      final fixedData = _trySanitizeTimetableEventData(raw);
      try {
        final parsed = TimetableEvent.fromJson(raw);
        final issues = fixedData == null
            ? <String>[]
            : _compareJson(raw, fixedData);
        if (issues.isNotEmpty) {
          invalid.add(
            InvalidEntry(
              id: doc.id,
              collection: 'timetable_events',
              rawData: raw,
              issues: issues,
              fixedData: fixedData,
            ),
          );
        }
        valid.add(parsed);
      } catch (e) {
        final issues = <String>['Parse error: $e'];
        if (fixedData != null) {
          issues.addAll(_compareJson(raw, fixedData));
        }
        invalid.add(
          InvalidEntry(
            id: doc.id,
            collection: 'timetable_events',
            rawData: raw,
            issues: issues,
            fixedData: fixedData,
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
    final normalizedData = switch (collection) {
      'treasure_points' => _sanitizeTreasurePointFixPayload(docId, data),
      'wiki_articles' => _sanitizeWikiArticleFixPayload(docId, data),
      'timetable_events' => _sanitizeTimetableEventFixPayload(docId, data),
      _ => data,
    };
    await _firestore.collection(collection).doc(docId).set(normalizedData);
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

  Map<String, dynamic> _sanitizeTreasurePointData(
    Map<String, dynamic> raw,
    TreasurePoint parsed,
  ) {
    final data = Map<String, dynamic>.from(parsed.toJson())..remove('id');

    final name = _sanitizeRequiredText(
      data['name'],
      fallback: 'Untitled point',
    );

    data['name'] = name;
    data['description'] = _sanitizeRequiredText(
      data['description'],
      fallback: name,
    );
    data['qrCode'] = _sanitizeQrCode(
      data['qrCode'],
      docId: raw['id'] as String?,
    );
    data['order'] = _sanitizeNonNegativeInt(data['order']);
    data['latitude'] = _sanitizeCoordinate(
      data['latitude'],
      min: -90,
      max: 90,
      fallback: _defaultCampusLatitude,
    );
    data['longitude'] = _sanitizeCoordinate(
      data['longitude'],
      min: -180,
      max: 180,
      fallback: _defaultCampusLongitude,
    );

    return data;
  }

  Map<String, dynamic> _sanitizeTreasurePointFixPayload(
    String docId,
    Map<String, dynamic> data,
  ) {
    final raw = Map<String, dynamic>.from(data)..['id'] = docId;
    final parsed = TreasurePoint.fromJson(raw);
    return _sanitizeTreasurePointData(raw, parsed);
  }

  Map<String, dynamic>? _trySanitizeWikiArticleData(Map<String, dynamic> raw) {
    try {
      return _sanitizeWikiArticleData(raw);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _sanitizeWikiArticleData(Map<String, dynamic> raw) {
    final title = _sanitizeRequiredText(
      raw['title'],
      fallback: 'Untitled article',
    );
    final candidate = <String, dynamic>{
      'id': (raw['id'] ?? '').toString(),
      'title': title,
      'content': _sanitizeRequiredText(raw['content'], fallback: title),
      'category': _sanitizeRequiredText(raw['category'], fallback: 'General'),
      'imageUrl': _sanitizeOptionalText(raw['imageUrl']),
      'tags': _sanitizeStringList(raw['tags']),
      'treasurePointIds': _sanitizeStringList(raw['treasurePointIds']),
    };

    final parsed = WikiArticle.fromJson(candidate);
    return Map<String, dynamic>.from(parsed.toJson())..remove('id');
  }

  Map<String, dynamic> _sanitizeWikiArticleFixPayload(
    String docId,
    Map<String, dynamic> data,
  ) {
    final raw = Map<String, dynamic>.from(data)..['id'] = docId;
    return _sanitizeWikiArticleData(raw);
  }

  Map<String, dynamic>? _trySanitizeTimetableEventData(
    Map<String, dynamic> raw,
  ) {
    try {
      return _sanitizeTimetableEventData(raw);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _sanitizeTimetableEventData(Map<String, dynamic> raw) {
    final title = _sanitizeRequiredText(
      raw['title'],
      fallback: 'Untitled event',
    );
    final fallbackEndCandidate = _tryParseDateTime(raw['endTime']);
    final fallbackStart = fallbackEndCandidate != null
        ? fallbackEndCandidate.subtract(const Duration(hours: 1))
        : _defaultEventStart();
    final startTime = _sanitizeDateTime(
      raw['startTime'],
      fallback: fallbackStart,
    );
    final endTime = _sanitizeEndDateTime(raw['endTime'], startTime: startTime);
    final candidate = <String, dynamic>{
      'id': (raw['id'] ?? '').toString(),
      'title': title,
      'description': _sanitizeRequiredText(raw['description'], fallback: title),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': _sanitizeRequiredText(
        raw['location'],
        fallback: 'SGGW Campus',
      ),
      'imageUrl': _sanitizeOptionalText(raw['imageUrl']),
      'tags': _sanitizeStringList(raw['tags']),
      'treasurePointIds': _sanitizeStringList(raw['treasurePointIds']),
    };

    final parsed = TimetableEvent.fromJson(candidate);
    return Map<String, dynamic>.from(parsed.toJson())..remove('id');
  }

  Map<String, dynamic> _sanitizeTimetableEventFixPayload(
    String docId,
    Map<String, dynamic> data,
  ) {
    final raw = Map<String, dynamic>.from(data)..['id'] = docId;
    return _sanitizeTimetableEventData(raw);
  }

  String _sanitizeRequiredText(Object? value, {required String fallback}) {
    final text = (value is String ? value : value?.toString() ?? '').trim();
    return text.isNotEmpty ? text : fallback;
  }

  String? _sanitizeOptionalText(Object? value) {
    final text = (value is String ? value : value?.toString() ?? '').trim();
    return text.isEmpty ? null : text;
  }

  List<String> _sanitizeStringList(Object? value) {
    final Iterable<Object?> items = switch (value) {
      Iterable<dynamic> iterable => iterable,
      String stringValue => stringValue.split(','),
      null => const <Object?>[],
      _ => [value],
    };

    final sanitized = <String>[];
    for (final item in items) {
      final text = (item is String ? item : item?.toString() ?? '').trim();
      if (text.isEmpty || sanitized.contains(text)) {
        continue;
      }
      sanitized.add(text);
    }
    return sanitized;
  }

  String _sanitizeQrCode(Object? value, {String? docId}) {
    final qrCode = (value is String ? value : value?.toString() ?? '').trim();
    if (qrCode.isNotEmpty) {
      return qrCode;
    }

    if (docId != null && docId.isNotEmpty) {
      return 'https://sggw-days.web.app/scan/$docId';
    }

    return 'https://sggw-days.web.app/scan';
  }

  int _sanitizeNonNegativeInt(Object? value) {
    final parsed = switch (value) {
      int intValue => intValue,
      num numValue => numValue.toInt(),
      _ => int.tryParse(value?.toString() ?? ''),
    };

    if (parsed == null || parsed < 0) {
      return 0;
    }

    return parsed;
  }

  double _sanitizeCoordinate(
    Object? value, {
    required double min,
    required double max,
    required double fallback,
  }) {
    final parsed = switch (value) {
      num numValue => numValue.toDouble(),
      _ => double.tryParse(value?.toString() ?? ''),
    };

    if (parsed == null) {
      return fallback;
    }

    return parsed.clamp(min, max).toDouble();
  }

  DateTime _defaultEventStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour);
  }

  DateTime? _tryParseDateTime(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) {
        return null;
      }
      final asEpoch = int.tryParse(text);
      if (asEpoch != null) {
        return DateTime.fromMillisecondsSinceEpoch(asEpoch);
      }
      return DateTime.tryParse(text);
    }
    return null;
  }

  DateTime _sanitizeDateTime(Object? value, {required DateTime fallback}) {
    return _tryParseDateTime(value) ?? fallback;
  }

  DateTime _sanitizeEndDateTime(Object? value, {required DateTime startTime}) {
    final endTime = _sanitizeDateTime(
      value,
      fallback: startTime.add(const Duration(hours: 1)),
    );
    if (!endTime.isAfter(startTime)) {
      return startTime.add(const Duration(hours: 1));
    }
    return endTime;
  }
}
