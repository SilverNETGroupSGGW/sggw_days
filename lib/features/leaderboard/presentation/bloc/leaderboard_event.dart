import 'package:equatable/equatable.dart';
import 'package:sggw_days/features/leaderboard/data/models/leaderboard_entry.dart';
import 'package:sggw_days/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeaderboards extends LeaderboardEvent {
  const LoadLeaderboards();
}

class PublishLeaderboardProgress extends LeaderboardEvent {
  final List<TreasurePoint> points;
  final List<String> foundPointIds;
  final List<String> checkedInIds;

  const PublishLeaderboardProgress({
    required this.points,
    required this.foundPointIds,
    required this.checkedInIds,
  });

  @override
  List<Object?> get props => [points, foundPointIds, checkedInIds];
}

class UpdateLeaderboardDisplayName extends LeaderboardEvent {
  final String displayName;

  const UpdateLeaderboardDisplayName(this.displayName);

  @override
  List<Object?> get props => [displayName];
}

class LeaderboardEntriesUpdated extends LeaderboardEvent {
  final LeaderboardMode mode;
  final List<LeaderboardEntry> entries;

  const LeaderboardEntriesUpdated({required this.mode, required this.entries});

  @override
  List<Object?> get props => [mode, entries];
}

class LeaderboardFailed extends LeaderboardEvent {
  final String message;

  const LeaderboardFailed(this.message);

  @override
  List<Object?> get props => [message];
}
