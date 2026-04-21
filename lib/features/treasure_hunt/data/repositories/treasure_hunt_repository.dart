import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

class TreasureHuntRepository {
  final FirebaseFirestore? _firestore;
  static const _cacheKey = 'treasure_points_cache';
  static const _fallbackPointType = 'pointOfInterest';

  TreasureHuntRepository({FirebaseFirestore? firestore})
    : _firestore = firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  Future<List<TreasurePoint>> getTreasurePoints() async {
    try {
      final snapshot = await firestore.collection('treasure_points').get();
      final points = <TreasurePoint>[];
      for (final doc in snapshot.docs) {
        try {
          final data = _normalizeTreasurePointData(doc.id, doc.data());
          points.add(TreasurePoint.fromJson(data));
        } catch (e) {
          debugPrint('Skipping treasure point ${doc.id}: $e');
        }
      }
      await _cacheData(points.map((p) => p.toJson()).toList());
      return points;
    } on FirebaseException {
      return await _loadFromCache();
    } catch (e) {
      debugPrint('TreasureHuntRepository error: $e');
      return await _loadFromCache();
    }
  }

  Future<void> _cacheData(List<Map<String, dynamic>> data) async {
    final box = await Hive.openBox('api_cache');
    await box.put(_cacheKey, jsonEncode(data));
  }

  Future<List<TreasurePoint>> _loadFromCache() async {
    final box = await Hive.openBox('api_cache');
    final cached = box.get(_cacheKey) as String?;
    if (cached != null) {
      final List<dynamic> data = jsonDecode(cached) as List<dynamic>;
      final points = <TreasurePoint>[];
      for (final json in data) {
        try {
          final normalized = _normalizeTreasurePointData(
            null,
            Map<String, dynamic>.from(json as Map),
          );
          points.add(TreasurePoint.fromJson(normalized));
        } catch (e) {
          debugPrint('Skipping cached treasure point: $e');
        }
      }
      return points;
    }
    return [];
  }

  Map<String, dynamic> _normalizeTreasurePointData(
    String? id,
    Map<String, dynamic> rawData,
  ) {
    final data = Map<String, dynamic>.from(rawData);
    if (id != null) {
      data['id'] = id;
    }

    data['latitude'] = _toDouble(data['latitude']);
    data['longitude'] = _toDouble(data['longitude']);
    data['order'] = _toInt(data['order']) ?? 0;
    data['type'] = _normalizePointType(data['type']);

    return data;
  }

  double? _toDouble(Object? value) {
    return switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text),
      _ => null,
    };
  }

  int? _toInt(Object? value) {
    return switch (value) {
      int number => number,
      num number => number.toInt(),
      String text => int.tryParse(text),
      _ => null,
    };
  }

  String _normalizePointType(Object? value) {
    final pointType = (value is String ? value : value?.toString() ?? '')
        .trim();
    if (pointType == 'treasurePoint' || pointType == 'pointOfInterest') {
      return pointType;
    }

    return _fallbackPointType;
  }
}
