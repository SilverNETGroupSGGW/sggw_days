import 'package:flutter_test/flutter_test.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';

void main() {
  const firstTreasure = TreasurePoint(
    id: 'treasure-1',
    name: 'First Treasure',
    description: 'First stop',
    latitude: 52.1598,
    longitude: 21.0463,
    qrCode: 'qr-1',
    type: PointType.treasurePoint,
    order: 0,
  );

  const secondTreasure = TreasurePoint(
    id: 'treasure-2',
    name: 'Second Treasure',
    description: 'Second stop',
    latitude: 52.16,
    longitude: 21.0465,
    qrCode: 'qr-2',
    type: PointType.treasurePoint,
    order: 1,
  );

  const pointOfInterest = TreasurePoint(
    id: 'poi-1',
    name: 'Library',
    description: 'Interesting place',
    latitude: 52.1602,
    longitude: 21.0468,
    qrCode: 'poi-qr',
    type: PointType.pointOfInterest,
  );

  test('hides points of interest before the first treasure scan', () {
    const state = TreasureHuntState(
      points: [firstTreasure, secondTreasure, pointOfInterest],
    );

    expect(
      state.visiblePointIds(skipTreasureHunt: false),
      equals({'treasure-1'}),
    );
  });

  test('reveals points of interest after the first treasure scan', () {
    const state = TreasureHuntState(
      points: [firstTreasure, secondTreasure, pointOfInterest],
      foundPointIds: ['treasure-1'],
    );

    expect(
      state.visiblePointIds(skipTreasureHunt: false),
      equals({'treasure-1', 'treasure-2', 'poi-1'}),
    );
  });

  test(
    'reveals points of interest immediately when treasure hunt is skipped',
    () {
      const state = TreasureHuntState(
        points: [firstTreasure, secondTreasure, pointOfInterest],
      );

      expect(
        state.visiblePointIds(skipTreasureHunt: true),
        equals({'treasure-1', 'poi-1'}),
      );
      expect(state.unlockedPointIds, equals({'treasure-1'}));
    },
  );
}
