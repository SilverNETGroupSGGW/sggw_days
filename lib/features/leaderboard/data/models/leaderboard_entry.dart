import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_entry.freezed.dart';
part 'leaderboard_entry.g.dart';

@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String participantId,
    required String displayName,
    @Default(0) int totalScore,
    @Default(0) int foundPointScore,
    @Default(0) int treasureScore,
    @Default(0) int checkInScore,
    DateTime? updatedAt,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}
