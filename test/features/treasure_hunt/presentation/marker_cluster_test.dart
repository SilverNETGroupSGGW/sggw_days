import 'package:flutter_test/flutter_test.dart';
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
