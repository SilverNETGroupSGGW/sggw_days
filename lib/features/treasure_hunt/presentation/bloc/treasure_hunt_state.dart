import 'package:equatable/equatable.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

enum TreasureHuntStatus { initial, loading, success, error }

class TreasureHuntState extends Equatable {
  final TreasureHuntStatus status;
  final List<TreasurePoint> points;
  final List<String> foundPointIds;
  final String? errorMessage;

  const TreasureHuntState({
    this.status = TreasureHuntStatus.initial,
    this.points = const [],
    this.foundPointIds = const [],
    this.errorMessage,
  });

  TreasureHuntState copyWith({
    TreasureHuntStatus? status,
    List<TreasurePoint>? points,
    List<String>? foundPointIds,
    String? errorMessage,
  }) {
    return TreasureHuntState(
      status: status ?? this.status,
      points: points ?? this.points,
      foundPointIds: foundPointIds ?? this.foundPointIds,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, points, foundPointIds, errorMessage];
}
