import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/marker_cluster.dart';

void main() {
  test('groups nearby points and keeps distant points separate', () {
    final clusters = clusterTreasurePoints([
      _point(id: 'poi', latitude: 52.159801, longitude: 21.046301),
      _point(
        id: 'treasure',
        latitude: 52.1598,
        longitude: 21.0463,
        type: PointType.treasurePoint,
      ),
      _point(id: 'far', latitude: 52.1608, longitude: 21.0473),
    ], radiusMeters: 18);

    expect(clusters, hasLength(2));
    expect(clusters.first.points.map((point) => point.id), ['treasure', 'poi']);
    expect(clusters.first.isCluster, isTrue);
    expect(clusters.last.points.single.id, 'far');
  });

  test('cluster radius follows screen scale instead of fixed meters', () {
    expect(
      clusterRadiusMetersForZoom(zoom: 16.25, latitude: 52.1598),
      closeTo(39.4, 1.0),
    );
    expect(
      clusterRadiusMetersForZoom(zoom: 18.25, latitude: 52.1598),
      closeTo(9.8, 0.5),
    );
  });

  test('merges points transitively when zooming out', () {
    final clusters = clusterTreasurePoints([
      _point(id: 'a', latitude: 52.1598, longitude: 21.0463),
      _point(id: 'b', latitude: 52.15989, longitude: 21.0463),
      _point(id: 'c', latitude: 52.15998, longitude: 21.0463),
      _point(id: 'far', latitude: 52.1606, longitude: 21.0463),
    ], radiusMeters: 12);

    expect(clusters, hasLength(2));
    expect(clusters.first.points.map((point) => point.id), ['a', 'b', 'c']);
    expect(clusters.last.points.single.id, 'far');
  });

  test('assigns display tiers that match map overlay hierarchy', () {
    final ordinaryPoint = TreasurePointCluster(
      center: const LatLng(52.1598, 21.0463),
      points: [_point(id: 'ordinary', latitude: 52.1598, longitude: 21.0463)],
    );
    final ordinaryCluster = TreasurePointCluster(
      center: const LatLng(52.15981, 21.04631),
      points: [
        _point(id: 'poi-a', latitude: 52.15981, longitude: 21.04631),
        _point(id: 'poi-b', latitude: 52.15982, longitude: 21.04632),
      ],
    );
    final activeTreasurePoint = TreasurePointCluster(
      center: const LatLng(52.15983, 21.04633),
      points: [
        _point(
          id: 'next-point',
          latitude: 52.15983,
          longitude: 21.04633,
          type: PointType.treasurePoint,
        ),
      ],
    );
    final activeTreasureCluster = TreasurePointCluster(
      center: const LatLng(52.15984, 21.04634),
      points: [
        _point(
          id: 'next-cluster',
          latitude: 52.15984,
          longitude: 21.04634,
          type: PointType.treasurePoint,
        ),
        _point(id: 'cluster-poi', latitude: 52.15985, longitude: 21.04635),
      ],
    );
    final focusedCluster = TreasurePointCluster(
      center: const LatLng(52.159845, 21.046345),
      points: [
        _point(id: 'cluster-focus', latitude: 52.159845, longitude: 21.046345),
        _point(id: 'cluster-other', latitude: 52.159846, longitude: 21.046346),
      ],
    );
    final focusedPoint = TreasurePointCluster(
      center: const LatLng(52.15986, 21.04636),
      points: [_point(id: 'focused', latitude: 52.15986, longitude: 21.04636)],
    );

    expect(
      treasurePointClusterDisplayTier(
        ordinaryPoint,
        foundPointIds: const {},
        nextTreasurePointId: 'next-point',
      ),
      TreasurePointClusterDisplayTier.ordinaryPoint,
    );
    expect(
      treasurePointClusterDisplayTier(
        ordinaryCluster,
        foundPointIds: const {},
        nextTreasurePointId: 'next-point',
      ),
      TreasurePointClusterDisplayTier.clusterWithoutActiveTreasure,
    );
    expect(
      treasurePointClusterDisplayTier(
        activeTreasurePoint,
        foundPointIds: const {},
        nextTreasurePointId: 'next-point',
      ),
      TreasurePointClusterDisplayTier.activeTreasurePoint,
    );
    expect(
      treasurePointClusterDisplayTier(
        activeTreasureCluster,
        foundPointIds: const {},
        nextTreasurePointId: 'next-cluster',
      ),
      TreasurePointClusterDisplayTier.clusterWithActiveTreasure,
    );
    expect(
      treasurePointClusterDisplayTier(
        focusedCluster,
        foundPointIds: const {},
        nextTreasurePointId: 'next-point',
        selectedPointId: 'cluster-focus',
      ),
      TreasurePointClusterDisplayTier.focusedCluster,
    );
    expect(
      treasurePointClusterDisplayTier(
        focusedPoint,
        foundPointIds: const {},
        nextTreasurePointId: 'next-point',
        selectedPointId: 'focused',
      ),
      TreasurePointClusterDisplayTier.focusedPoint,
    );
  });

  test('returns the highlighted point from a cluster', () {
    final cluster = TreasurePointCluster(
      center: const LatLng(52.15984, 21.04634),
      points: [
        _point(id: 'selected', latitude: 52.15984, longitude: 21.04634),
        _point(id: 'tracked', latitude: 52.15985, longitude: 21.04635),
      ],
    );

    expect(
      highlightedPointInCluster(cluster, selectedPointId: 'selected')?.id,
      'selected',
    );
    expect(
      highlightedPointInCluster(
        cluster,
        selectedPointId: 'selected',
        trackedPointId: 'tracked',
      )?.id,
      'tracked',
    );
  });

  test('sorts clusters from lowest to highest display priority', () {
    final ordinaryPoint = TreasurePointCluster(
      center: const LatLng(52.1598, 21.0463),
      points: [_point(id: 'ordinary', latitude: 52.1598, longitude: 21.0463)],
    );
    final ordinaryCluster = TreasurePointCluster(
      center: const LatLng(52.15981, 21.04631),
      points: [
        _point(id: 'poi-a', latitude: 52.15981, longitude: 21.04631),
        _point(id: 'poi-b', latitude: 52.15982, longitude: 21.04632),
      ],
    );
    final activeTreasureCluster = TreasurePointCluster(
      center: const LatLng(52.15983, 21.04633),
      points: [
        _point(
          id: 'next',
          latitude: 52.15983,
          longitude: 21.04633,
          type: PointType.treasurePoint,
        ),
        _point(id: 'cluster-poi', latitude: 52.15984, longitude: 21.04634),
      ],
    );
    final focusedPoint = TreasurePointCluster(
      center: const LatLng(52.15985, 21.04635),
      points: [_point(id: 'focused', latitude: 52.15985, longitude: 21.04635)],
    );

    final sorted = sortTreasurePointClustersForDisplay(
      [focusedPoint, activeTreasureCluster, ordinaryCluster, ordinaryPoint],
      foundPointIds: const {},
      nextTreasurePointId: 'next',
      trackedPointId: 'focused',
    );

    expect(
      sorted.map((cluster) => cluster.points.map((point) => point.id).toList()),
      [
        ['ordinary'],
        ['poi-a', 'poi-b'],
        ['next', 'cluster-poi'],
        ['focused'],
      ],
    );
  });
}

TreasurePoint _point({
  required String id,
  required double latitude,
  required double longitude,
  PointType type = PointType.pointOfInterest,
}) {
  return TreasurePoint(
    id: id,
    name: id,
    description: 'Description',
    latitude: latitude,
    longitude: longitude,
    qrCode: 'https://sggw-days.web.app/scan/$id',
    type: type,
  );
}
