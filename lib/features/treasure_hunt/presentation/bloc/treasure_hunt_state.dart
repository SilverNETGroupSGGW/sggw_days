import 'package:equatable/equatable.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

enum TreasureHuntStatus { initial, loading, success, error }

class TreasureHuntState extends Equatable {
  final TreasureHuntStatus status;
  final List<TreasurePoint> points;
  final List<String> foundPointIds;
  final String? errorMessage;
  final int totalScore;

  const TreasureHuntState({
    this.status = TreasureHuntStatus.initial,
    this.points = const [],
    this.foundPointIds = const [],
    this.errorMessage,
    this.totalScore = 0,
  });

  TreasureHuntState copyWith({
    TreasureHuntStatus? status,
    List<TreasurePoint>? points,
    List<String>? foundPointIds,
    String? errorMessage,
    int? totalScore,
  }) {
    return TreasureHuntState(
      status: status ?? this.status,
      points: points ?? this.points,
      foundPointIds: foundPointIds ?? this.foundPointIds,
      errorMessage: errorMessage,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    points,
    foundPointIds,
    errorMessage,
    totalScore,
  ];
}
