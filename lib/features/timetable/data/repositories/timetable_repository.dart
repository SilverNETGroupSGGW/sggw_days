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
      final events = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Convert Firestore Timestamps to ISO strings for Freezed deserialization
        if (data['startTime'] is Timestamp) {
          data['startTime'] = (data['startTime'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        if (data['endTime'] is Timestamp) {
          data['endTime'] = (data['endTime'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        return TimetableEvent.fromJson(data);
      }).toList();
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
      return data
          .map((json) => TimetableEvent.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
