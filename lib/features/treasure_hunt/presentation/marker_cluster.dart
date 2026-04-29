import 'package:latlong2/latlong.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

class TreasurePointCluster {
  final LatLng center;
  final List<TreasurePoint> points;

  const TreasurePointCluster({required this.center, required this.points});

  bool get isCluster => points.length > 1;
}

List<TreasurePointCluster> clusterTreasurePoints(
  Iterable<TreasurePoint> points, {
  double radiusMeters = 18,
}) {
  final distance = const Distance();
  final clusters = <_MutableTreasurePointCluster>[];
  final sortedPoints = points.toList()..sort(_compareTreasurePoints);

  for (final point in sortedPoints) {
    final pointLatLng = LatLng(point.latitude, point.longitude);
    _MutableTreasurePointCluster? matchingCluster;
    for (final cluster in clusters) {
      if (distance(pointLatLng, cluster.center) <= radiusMeters) {
        matchingCluster = cluster;
        break;
      }
    }

    if (matchingCluster == null) {
      clusters.add(_MutableTreasurePointCluster(pointLatLng, [point]));
    } else {
      matchingCluster.add(point);
    }
  }

  return clusters
      .map(
        (cluster) => TreasurePointCluster(
          center: cluster.center,
          points: List.unmodifiable(
            cluster.points..sort(_compareTreasurePoints),
          ),
        ),
      )
      .toList();
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

class _MutableTreasurePointCluster {
  LatLng center;
  final List<TreasurePoint> points;

  _MutableTreasurePointCluster(this.center, this.points);

  void add(TreasurePoint point) {
    points.add(point);
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
    center = LatLng(latitude, longitude);
  }
}
