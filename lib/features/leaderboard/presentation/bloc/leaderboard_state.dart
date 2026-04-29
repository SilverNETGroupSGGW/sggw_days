import 'package:equatable/equatable.dart';
import 'package:sggw_days/features/leaderboard/data/models/leaderboard_entry.dart';

enum LeaderboardStatus { initial, loading, success, error }

class LeaderboardState extends Equatable {
  final LeaderboardStatus status;
  final String? participantId;
  final String displayName;
  final List<LeaderboardEntry> overallEntries;
  final List<LeaderboardEntry> treasureEntries;
  final String? errorMessage;

  const LeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.participantId,
    this.displayName = '',
    this.overallEntries = const [],
    this.treasureEntries = const [],
    this.errorMessage,
  });

  LeaderboardEntry? get currentOverallEntry => participantId == null
      ? null
      : overallEntries
            .where((entry) => entry.participantId == participantId)
            .firstOrNull;

  LeaderboardEntry? get currentTreasureEntry => participantId == null
      ? null
      : treasureEntries
            .where((entry) => entry.participantId == participantId)
            .firstOrNull;

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    String? participantId,
    String? displayName,
    List<LeaderboardEntry>? overallEntries,
    List<LeaderboardEntry>? treasureEntries,
    String? errorMessage,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      participantId: participantId ?? this.participantId,
      displayName: displayName ?? this.displayName,
      overallEntries: overallEntries ?? this.overallEntries,
      treasureEntries: treasureEntries ?? this.treasureEntries,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    participantId,
    displayName,
    overallEntries,
    treasureEntries,
    errorMessage,
  ];
}
