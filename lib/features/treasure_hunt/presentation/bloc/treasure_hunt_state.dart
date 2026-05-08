import 'package:equatable/equatable.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

enum TreasureHuntStatus { initial, loading, success, error }

enum TreasureHuntScanFeedback { alreadyScanned }

class TreasureHuntState extends Equatable {
  final TreasureHuntStatus status;
  final List<TreasurePoint> points;
  final List<String> foundPointIds;
  final Map<String, DateTime> scanHistory;
  final String? errorMessage;
  final String? trackedPointId;
  final String? lastScannedPointId;
  final TreasureHuntScanFeedback? scanFeedback;
  final int scanFeedbackVersion;

  const TreasureHuntState({
    this.status = TreasureHuntStatus.initial,
    this.points = const [],
    this.foundPointIds = const [],
    this.scanHistory = const {},
    this.errorMessage,
    this.trackedPointId,
    this.lastScannedPointId,
    this.scanFeedback,
    this.scanFeedbackVersion = 0,
  });

  /// Returns treasure points sorted by order.
  List<TreasurePoint> get sortedTreasurePoints {
    final tp = points.where((p) => p.type == PointType.treasurePoint).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return tp;
  }

  bool get hasFoundAnyTreasurePoint {
    return sortedTreasurePoints.any((p) => foundPointIds.contains(p.id));
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
    if (hasFoundAnyTreasurePoint) {
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

  /// Returns the set of point IDs that should be shown in the UI.
  /// Skipping the treasure hunt reveals points of interest immediately,
  /// while scan/QR progression still relies on [unlockedPointIds].
  Set<String> visiblePointIds({required bool skipTreasureHunt}) {
    final visible = <String>{...unlockedPointIds};

    if (skipTreasureHunt) {
      for (final point in points) {
        if (point.type == PointType.pointOfInterest) {
          visible.add(point.id);
        }
      }
    }

    return visible;
  }

  /// [errorMessage], [lastScannedPointId], and [scanFeedback] are transient
  /// UI-event flags.
  /// They intentionally reset on unrelated emits so listeners fire once.
  TreasureHuntState copyWith({
    TreasureHuntStatus? status,
    List<TreasurePoint>? points,
    List<String>? foundPointIds,
    Map<String, DateTime>? scanHistory,
    String? errorMessage,
    String? trackedPointId,
    String? lastScannedPointId,
    TreasureHuntScanFeedback? scanFeedback,
    int? scanFeedbackVersion,
  }) {
    return TreasureHuntState(
      status: status ?? this.status,
      points: points ?? this.points,
      foundPointIds: foundPointIds ?? this.foundPointIds,
      scanHistory: scanHistory ?? this.scanHistory,
      errorMessage: errorMessage,
      trackedPointId: trackedPointId ?? this.trackedPointId,
      lastScannedPointId: lastScannedPointId,
      scanFeedback: scanFeedback,
      scanFeedbackVersion: scanFeedbackVersion ?? this.scanFeedbackVersion,
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
    scanFeedback,
    scanFeedbackVersion,
  ];
}
