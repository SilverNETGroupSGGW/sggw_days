import 'package:equatable/equatable.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

enum TreasureHuntStatus { initial, loading, success, error }

class TreasureHuntState extends Equatable {
  final TreasureHuntStatus status;
  final List<TreasurePoint> points;
  final List<String> foundPointIds;
  final Map<String, DateTime> scanHistory;
  final String? errorMessage;
  final String? trackedPointId;
  final String? lastScannedPointId;

  const TreasureHuntState({
    this.status = TreasureHuntStatus.initial,
    this.points = const [],
    this.foundPointIds = const [],
    this.scanHistory = const {},
    this.errorMessage,
    this.trackedPointId,
    this.lastScannedPointId,
  });

  /// Returns treasure points sorted by order.
  List<TreasurePoint> get sortedTreasurePoints {
    final tp = points.where((p) => p.type == PointType.treasurePoint).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return tp;
  }

  /// Returns the set of unlocked point IDs based on sequential logic.
  /// The first treasure point is always visible.
  /// Scanning the Nth treasure point unlocks the (N+1)th.
  /// Also, scanning the first treasure point unlocks all non-treasure points.
  Set<String> get unlockedPointIds {
    final sorted = sortedTreasurePoints;
    final unlocked = <String>{};

    // First treasure point is always unlocked
    if (sorted.isNotEmpty) {
      unlocked.add(sorted.first.id);
    }

    // Walk through the ordered treasure points
    for (var i = 0; i < sorted.length; i++) {
      if (foundPointIds.contains(sorted[i].id)) {
        // This point was found, unlock the next one
        if (i + 1 < sorted.length) {
          unlocked.add(sorted[i + 1].id);
        }
      }
    }

    // If user has scanned at least one treasure point, unlock all non-treasure points
    final hasFoundAnyTreasure = sorted.any((p) => foundPointIds.contains(p.id));
    if (hasFoundAnyTreasure) {
      for (final p in points) {
        if (p.type != PointType.treasurePoint) {
          unlocked.add(p.id);
        }
      }
    }

    // Already found points are always unlocked
    unlocked.addAll(foundPointIds);

    return unlocked;
  }

  TreasureHuntState copyWith({
    TreasureHuntStatus? status,
    List<TreasurePoint>? points,
    List<String>? foundPointIds,
    Map<String, DateTime>? scanHistory,
    String? errorMessage,
    String? trackedPointId,
    String? lastScannedPointId,
  }) {
    return TreasureHuntState(
      status: status ?? this.status,
      points: points ?? this.points,
      foundPointIds: foundPointIds ?? this.foundPointIds,
      scanHistory: scanHistory ?? this.scanHistory,
      errorMessage: errorMessage,
      trackedPointId: trackedPointId ?? this.trackedPointId,
      lastScannedPointId: lastScannedPointId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    points,
    foundPointIds,
    scanHistory,
    errorMessage,
    trackedPointId,
    lastScannedPointId,
  ];
}
