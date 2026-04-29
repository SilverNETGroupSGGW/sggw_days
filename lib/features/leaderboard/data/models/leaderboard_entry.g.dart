// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    _LeaderboardEntry(
      participantId: json['participantId'] as String,
      displayName: json['displayName'] as String,
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
      foundPointScore: (json['foundPointScore'] as num?)?.toInt() ?? 0,
      treasureScore: (json['treasureScore'] as num?)?.toInt() ?? 0,
      checkInScore: (json['checkInScore'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LeaderboardEntryToJson(_LeaderboardEntry instance) =>
    <String, dynamic>{
      'participantId': instance.participantId,
      'displayName': instance.displayName,
      'totalScore': instance.totalScore,
      'foundPointScore': instance.foundPointScore,
      'treasureScore': instance.treasureScore,
      'checkInScore': instance.checkInScore,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
