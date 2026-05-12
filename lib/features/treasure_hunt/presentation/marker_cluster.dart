import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

const double kTreasurePointClusterRadiusPx = 32;

double clusterRadiusMetersForZoom({
  required double zoom,
  required double latitude,
  double clusterRadiusPx = kTreasurePointClusterRadiusPx,
}) {
  final latitudeRadians = latitude * (math.pi / 180);
  final metersPerPixel =
      156543.03392 * math.cos(latitudeRadians) / math.pow(2, zoom);
  return metersPerPixel * clusterRadiusPx;
}

class TreasurePointCluster {
  final LatLng center;
  final List<TreasurePoint> points;

  const TreasurePointCluster({required this.center, required this.points});

  bool get isCluster => points.length > 1;
}

enum TreasurePointClusterDisplayTier {
  ordinaryPoint(0),
  clusterWithoutActiveTreasure(1),
  activeTreasurePoint(2),
  clusterWithActiveTreasure(3),
  focusedCluster(4),
  focusedPoint(5);

  const TreasurePointClusterDisplayTier(this.priority);

  final int priority;
}

List<TreasurePointCluster> clusterTreasurePoints(
  Iterable<TreasurePoint> points, {
  double radiusMeters = 18,
}) {
  final distance = const Distance();
  final sortedPoints = points.toList()..sort(_compareTreasurePoints);
  final pointLocations = sortedPoints
      .map((point) => LatLng(point.latitude, point.longitude))
      .toList(growable: false);
  final visited = List<bool>.filled(sortedPoints.length, false);
  final clusters = <TreasurePointCluster>[];

  for (var index = 0; index < sortedPoints.length; index++) {
    if (visited[index]) continue;

    final pending = <int>[index];
    final clusterPoints = <TreasurePoint>[];
    visited[index] = true;

    for (var pendingIndex = 0; pendingIndex < pending.length; pendingIndex++) {
      final currentIndex = pending[pendingIndex];
      clusterPoints.add(sortedPoints[currentIndex]);

      for (
        var candidateIndex = 0;
        candidateIndex < sortedPoints.length;
        candidateIndex++
      ) {
        if (visited[candidateIndex]) continue;
        if (distance(
              pointLocations[currentIndex],
              pointLocations[candidateIndex],
            ) <=
            radiusMeters) {
          visited[candidateIndex] = true;
          pending.add(candidateIndex);
        }
      }
    }

    clusterPoints.sort(_compareTreasurePoints);
    clusters.add(
      TreasurePointCluster(
        center: _clusterCenter(clusterPoints),
        points: List.unmodifiable(clusterPoints),
      ),
    );
  }

  return clusters;
}

List<TreasurePointCluster> sortTreasurePointClustersForDisplay(
  Iterable<TreasurePointCluster> clusters, {
  required Set<String> foundPointIds,
  required String? nextTreasurePointId,
  String? selectedPointId,
  String? trackedPointId,
}) {
  final indexedClusters = [
    for (var index = 0; index < clusters.length; index++)
      (index: index, cluster: clusters.elementAt(index)),
  ];

  indexedClusters.sort((a, b) {
    final tierCompare =
        treasurePointClusterDisplayTier(
          a.cluster,
          foundPointIds: foundPointIds,
          nextTreasurePointId: nextTreasurePointId,
          selectedPointId: selectedPointId,
          trackedPointId: trackedPointId,
        ).priority.compareTo(
          treasurePointClusterDisplayTier(
            b.cluster,
            foundPointIds: foundPointIds,
            nextTreasurePointId: nextTreasurePointId,
            selectedPointId: selectedPointId,
            trackedPointId: trackedPointId,
          ).priority,
        );

    if (tierCompare != 0) return tierCompare;
    return a.index.compareTo(b.index);
  });

  return indexedClusters.map((entry) => entry.cluster).toList();
}

TreasurePointClusterDisplayTier treasurePointClusterDisplayTier(
  TreasurePointCluster cluster, {
  required Set<String> foundPointIds,
  required String? nextTreasurePointId,
  String? selectedPointId,
  String? trackedPointId,
}) {
  final highlightedPoint = highlightedPointInCluster(
    cluster,
    selectedPointId: selectedPointId,
    trackedPointId: trackedPointId,
  );

  if (!cluster.isCluster) {
    final point = cluster.points.single;
    if (point.id == selectedPointId || point.id == trackedPointId) {
      return TreasurePointClusterDisplayTier.focusedPoint;
    }
    if (_isActiveTreasurePoint(
      point,
      foundPointIds: foundPointIds,
      nextTreasurePointId: nextTreasurePointId,
    )) {
      return TreasurePointClusterDisplayTier.activeTreasurePoint;
    }
    return TreasurePointClusterDisplayTier.ordinaryPoint;
  }

  if (highlightedPoint != null) {
    return TreasurePointClusterDisplayTier.focusedCluster;
  }

  if (cluster.points.any(
    (point) => _isActiveTreasurePoint(
      point,
      foundPointIds: foundPointIds,
      nextTreasurePointId: nextTreasurePointId,
    ),
  )) {
    return TreasurePointClusterDisplayTier.clusterWithActiveTreasure;
  }

  return TreasurePointClusterDisplayTier.clusterWithoutActiveTreasure;
}

TreasurePoint? highlightedPointInCluster(
  TreasurePointCluster cluster, {
  String? selectedPointId,
  String? trackedPointId,
}) {
  if (!cluster.isCluster) return null;

  if (trackedPointId != null) {
    for (final point in cluster.points) {
      if (point.id == trackedPointId) return point;
    }
  }

  if (selectedPointId != null) {
    for (final point in cluster.points) {
      if (point.id == selectedPointId) return point;
    }
  }

  return null;
}

bool _isActiveTreasurePoint(
  TreasurePoint point, {
  required Set<String> foundPointIds,
  required String? nextTreasurePointId,
}) {
  return point.type == PointType.treasurePoint &&
      !foundPointIds.contains(point.id) &&
      point.id == nextTreasurePointId;
}

int _compareTreasurePoints(TreasurePoint a, TreasurePoint b) {
  final typeCompare = _pointTypePriority(a).compareTo(_pointTypePriority(b));
  if (typeCompare != 0) return typeCompare;
  final orderCompare = a.order.compareTo(b.order);
  if (orderCompare != 0) return orderCompare;
  return a.name.compareTo(b.name);
}

int _pointTypePriority(TreasurePoint point) {
  return point.type == PointType.treasurePoint ? 0 : 1;
}

LatLng _clusterCenter(List<TreasurePoint> points) {
  final latitude =
      points
          .map((point) => point.latitude)
          .reduce((value, element) => value + element) /
      points.length;
  final longitude =
      points
          .map((point) => point.longitude)
          .reduce((value, element) => value + element) /
      points.length;
  return LatLng(latitude, longitude);
}
