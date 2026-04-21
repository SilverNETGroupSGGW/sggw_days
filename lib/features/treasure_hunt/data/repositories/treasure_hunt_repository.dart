import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

class TreasureHuntRepository {
  final FirebaseFirestore? _firestore;
  static const _cacheKey = 'treasure_points_cache';

  TreasureHuntRepository({FirebaseFirestore? firestore})
    : _firestore = firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  Future<List<TreasurePoint>> getTreasurePoints() async {
    try {
      final snapshot = await firestore.collection('treasure_points').get();
      final points = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TreasurePoint.fromJson(data);
      }).toList();
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
      return data
          .map((json) => TreasurePoint.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
