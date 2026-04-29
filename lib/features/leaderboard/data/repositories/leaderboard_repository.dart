import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/leaderboard/data/models/leaderboard_entry.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

enum LeaderboardMode { overall, treasureHunt }

class LeaderboardScores {
  final int totalScore;
  final int foundPointScore;
  final int treasureScore;
  final int checkInScore;

  const LeaderboardScores({
    required this.totalScore,
    required this.foundPointScore,
    required this.treasureScore,
    required this.checkInScore,
  });

  String get signature =>
      '$totalScore|$foundPointScore|$treasureScore|$checkInScore';
}

LeaderboardScores calculateLeaderboardScores({
  required List<TreasurePoint> points,
  required Iterable<String> foundPointIds,
  required Iterable<String> checkedInIds,
}) {
  final foundPointSet = foundPointIds.toSet();
  final checkedInSet = checkedInIds.toSet();
  final treasurePointIds = points
      .where((point) => point.type == PointType.treasurePoint)
      .map((point) => point.id)
      .toSet();

  final treasureScore = treasurePointIds.isEmpty
      ? foundPointSet.length
      : foundPointSet.intersection(treasurePointIds).length;
  final foundPointScore = foundPointSet.length;
  final checkInScore = checkedInSet.length;

  return LeaderboardScores(
    totalScore: foundPointScore + checkInScore,
    foundPointScore: foundPointScore,
    treasureScore: treasureScore,
    checkInScore: checkInScore,
  );
}

String sanitizeLeaderboardDisplayName(String value) {
  final compact = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (compact.isEmpty) return '';
  if (compact.length <= 24) return compact;
  return compact.substring(0, 24).trim();
}

class LeaderboardRepository {
  static const _collection = 'leaderboard_entries';
  static const _participantIdKey = 'leaderboard_participant_id';
  static const _displayNameKey = 'leaderboard_display_name';
  static const _overallCacheKey = 'leaderboard_overall_cache';
  static const _treasureCacheKey = 'leaderboard_treasure_cache';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Box<dynamic> _settingsBox;

  LeaderboardRepository({
    required Box<dynamic> settingsBox,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _settingsBox = settingsBox,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  Future<({String participantId, String displayName})>
  ensureParticipant() async {
    final participantId = await _participantId();
    final displayName = await _displayName(participantId);
    return (participantId: participantId, displayName: displayName);
  }

  Stream<List<LeaderboardEntry>> watchLeaderboard(LeaderboardMode mode) {
    final field = switch (mode) {
      LeaderboardMode.overall => 'totalScore',
      LeaderboardMode.treasureHunt => 'treasureScore',
    };
    final cacheKey = switch (mode) {
      LeaderboardMode.overall => _overallCacheKey,
      LeaderboardMode.treasureHunt => _treasureCacheKey,
    };

    return _watchEntries(orderField: field, cacheKey: cacheKey, mode: mode);
  }

  Future<bool> publishProgress({
    required List<TreasurePoint> points,
    required List<String> foundPointIds,
    required List<String> checkedInIds,
  }) async {
    final participant = await ensureParticipant();
    final scores = calculateLeaderboardScores(
      points: points,
      foundPointIds: foundPointIds,
      checkedInIds: checkedInIds,
    );

    try {
      await _firestore
          .collection(_collection)
          .doc(participant.participantId)
          .set({
            'participantId': participant.participantId,
            'displayName': participant.displayName,
            'totalScore': scores.totalScore,
            'foundPointScore': scores.foundPointScore,
            'treasureScore': scores.treasureScore,
            'checkInScore': scores.checkInScore,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return true;
    } catch (error) {
      debugPrint('Leaderboard publish failed: $error');
      return false;
    }
  }

  Future<String> updateDisplayName(String value) async {
    final sanitized = sanitizeLeaderboardDisplayName(value);
    if (sanitized.isEmpty) {
      throw ArgumentError('Display name is required.');
    }

    final participantId = await _participantId();
    await _settingsBox.put(_displayNameKey, sanitized);

    try {
      await _firestore.collection(_collection).doc(participantId).update({
        'displayName': sanitized,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      if (error.code != 'not-found') {
        debugPrint('Leaderboard display name update failed: $error');
      }
    } catch (error) {
      debugPrint('Leaderboard display name update failed: $error');
    }

    return sanitized;
  }

  Stream<List<LeaderboardEntry>> _watchEntries({
    required String orderField,
    required String cacheKey,
    required LeaderboardMode mode,
  }) async* {
    final cached = await _loadCached(cacheKey, mode);
    if (cached.isNotEmpty) {
      yield cached;
    }

    try {
      await for (final snapshot
          in _firestore
              .collection(_collection)
              .orderBy(orderField, descending: true)
              .limit(50)
              .snapshots()) {
        final entries = _sortEntries(
          snapshot.docs.map(_parseEntry).whereType<LeaderboardEntry>().toList(),
          mode,
        );
        await _cacheEntries(cacheKey, entries);
        yield entries;
      }
    } catch (error) {
      debugPrint('Leaderboard stream failed: $error');
      if (cached.isEmpty) {
        yield const [];
      }
    }
  }

  LeaderboardEntry? _parseEntry(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    try {
      return LeaderboardEntry.fromJson(_normalizeEntryData(doc.id, doc.data()));
    } catch (error) {
      debugPrint('Skipping leaderboard entry ${doc.id}: $error');
      return null;
    }
  }

  Map<String, dynamic> _normalizeEntryData(
    String? id,
    Map<String, dynamic> rawData,
  ) {
    final data = Map<String, dynamic>.from(rawData);
    data['participantId'] = _toRequiredString(data['participantId'], id);
    data['displayName'] = _toRequiredString(data['displayName'], 'Player');
    data['totalScore'] = _toInt(data['totalScore']);
    data['foundPointScore'] = _toInt(data['foundPointScore']);
    data['treasureScore'] = _toInt(data['treasureScore']);
    data['checkInScore'] = _toInt(data['checkInScore']);
    data['updatedAt'] = _toIsoString(data['updatedAt']);
    return data;
  }

  List<LeaderboardEntry> _sortEntries(
    List<LeaderboardEntry> entries,
    LeaderboardMode mode,
  ) {
    return List<LeaderboardEntry>.from(entries)..sort((a, b) {
      final primary = switch (mode) {
        LeaderboardMode.overall => b.totalScore.compareTo(a.totalScore),
        LeaderboardMode.treasureHunt => b.treasureScore.compareTo(
          a.treasureScore,
        ),
      };
      if (primary != 0) return primary;

      final secondary = b.foundPointScore.compareTo(a.foundPointScore);
      if (secondary != 0) return secondary;

      final aUpdated = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bUpdated = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aUpdated.compareTo(bUpdated);
    });
  }

  Future<void> _cacheEntries(
    String cacheKey,
    List<LeaderboardEntry> entries,
  ) async {
    final box = await Hive.openBox('api_cache');
    await box.put(
      cacheKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<LeaderboardEntry>> _loadCached(
    String cacheKey,
    LeaderboardMode mode,
  ) async {
    final box = await Hive.openBox('api_cache');
    final cached = box.get(cacheKey) as String?;
    if (cached == null) return const [];

    try {
      final data = jsonDecode(cached) as List<dynamic>;
      final entries = data
          .map(
            (item) => LeaderboardEntry.fromJson(
              _normalizeEntryData(null, Map<String, dynamic>.from(item as Map)),
            ),
          )
          .toList();
      return _sortEntries(entries, mode);
    } catch (error) {
      debugPrint('Leaderboard cache read failed: $error');
      return const [];
    }
  }

  Future<String> _participantId() async {
    final authId = await _authenticatedParticipantId();
    if (authId != null && authId.isNotEmpty) {
      await _settingsBox.put(_participantIdKey, authId);
      return authId;
    }

    final existing = _settingsBox.get(_participantIdKey) as String?;
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final id = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    await _settingsBox.put(_participantIdKey, id);
    return id;
  }

  Future<String?> _authenticatedParticipantId() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) return currentUser.uid;
      final credential = await _auth.signInAnonymously();
      return credential.user?.uid;
    } on FirebaseAuthException catch (error) {
      debugPrint('Anonymous leaderboard sign-in failed: ${error.code}');
      return null;
    } catch (error) {
      debugPrint('Anonymous leaderboard sign-in failed: $error');
      return null;
    }
  }

  Future<String> _displayName(String participantId) async {
    final existing = _settingsBox.get(_displayNameKey) as String?;
    final sanitizedExisting = existing == null
        ? ''
        : sanitizeLeaderboardDisplayName(existing);
    if (sanitizedExisting.isNotEmpty) return sanitizedExisting;

    final generated = 'Player ${participantId.substring(0, 4).toUpperCase()}';
    await _settingsBox.put(_displayNameKey, generated);
    return generated;
  }

  String _toRequiredString(Object? value, String? fallback) {
    final text = (value is String ? value : value?.toString() ?? '').trim();
    if (text.isNotEmpty) return text;
    return fallback ?? 'unknown';
  }

  int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String? _toIsoString(Object? value) {
    return switch (value) {
      Timestamp timestamp => timestamp.toDate().toIso8601String(),
      DateTime dateTime => dateTime.toIso8601String(),
      String text when text.trim().isNotEmpty => text,
      _ => null,
    };
  }
}
