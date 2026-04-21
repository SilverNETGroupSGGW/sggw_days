import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';

class TimetableRepository {
  final FirebaseFirestore _firestore;
  static const _cacheKey = 'timetable_events_cache';

  TimetableRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<TimetableEvent>> getEvents() async {
    try {
      final snapshot = await _firestore.collection('timetable_events').get();
      final events = <TimetableEvent>[];
      for (final doc in snapshot.docs) {
        try {
          final data = _normalizeTimetableEventData(doc.id, doc.data());
          events.add(TimetableEvent.fromJson(data));
        } catch (e) {
          debugPrint('Skipping timetable event ${doc.id}: $e');
        }
      }
      await _cacheData(events.map((e) => e.toJson()).toList());
      return events;
    } on FirebaseException {
      return await _loadFromCache();
    } catch (e) {
      debugPrint('TimetableRepository error: $e');
      return await _loadFromCache();
    }
  }

  Future<List<TimetableEvent>> getEventsByDate(DateTime date) async {
    final events = await getEvents();
    return events.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList();
  }

  Future<void> _cacheData(List<Map<String, dynamic>> data) async {
    final box = await Hive.openBox('api_cache');
    await box.put(_cacheKey, jsonEncode(data));
  }

  Future<List<TimetableEvent>> _loadFromCache() async {
    final box = await Hive.openBox('api_cache');
    final cached = box.get(_cacheKey) as String?;
    if (cached != null) {
      final List<dynamic> data = jsonDecode(cached) as List<dynamic>;
      final events = <TimetableEvent>[];
      for (final json in data) {
        try {
          final normalized = _normalizeTimetableEventData(
            null,
            Map<String, dynamic>.from(json as Map),
          );
          events.add(TimetableEvent.fromJson(normalized));
        } catch (e) {
          debugPrint('Skipping cached timetable event: $e');
        }
      }
      return events;
    }
    return [];
  }

  Map<String, dynamic> _normalizeTimetableEventData(
    String? id,
    Map<String, dynamic> rawData,
  ) {
    final data = Map<String, dynamic>.from(rawData);
    if (id != null) {
      data['id'] = id;
    }

    data['startTime'] = _toIsoString(data['startTime']);
    data['endTime'] = _toIsoString(data['endTime']);
    data['imageUrl'] = _toNullableString(data['imageUrl']);
    data['tags'] = _toStringList(data['tags']);
    data['treasurePointIds'] = _toStringList(data['treasurePointIds']);

    if (!_hasRequiredText(data['title']) ||
        !_hasRequiredText(data['description']) ||
        !_hasRequiredText(data['location']) ||
        data['startTime'] == null ||
        data['endTime'] == null) {
      throw const FormatException('Missing required timetable event fields');
    }

    return data;
  }

  bool _hasRequiredText(Object? value) {
    return (value is String ? value : value?.toString() ?? '')
        .trim()
        .isNotEmpty;
  }

  String? _toIsoString(Object? value) {
    return switch (value) {
      Timestamp timestamp => timestamp.toDate().toIso8601String(),
      DateTime dateTime => dateTime.toIso8601String(),
      String text when text.trim().isNotEmpty => text,
      _ => null,
    };
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
