import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/core/config/scan_distance_config.dart';
import 'package:sggw_days/core/device/device_identity_service.dart';
import 'package:sggw_days/features/rewards/data/repositories/reward_repository.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_state.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';

class _FakeSettingsBox extends Fake implements Box<dynamic> {}

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

  final completedTreasureHuntState = TreasureHuntState(
    points: const [firstTreasure, secondTreasure],
    foundPointIds: const ['treasure-1', 'treasure-2'],
  );

  RewardRepository buildRepository({required bool rewardRequiresEventCheckIn}) {
    return RewardRepository(
      deviceIdentityService: DeviceIdentityService(
        settingsBox: _FakeSettingsBox(),
      ),
      scanDistanceConfig: ScanDistanceConfig.fallback(
        rewardRequiresEventCheckIn: rewardRequiresEventCheckIn,
      ),
    );
  }

  test('preserves event check-in gating when the flag is enabled', () {
    final repository = buildRepository(rewardRequiresEventCheckIn: true);

    final withoutEventCheckIn = repository.eligibility(
      treasureHuntState: completedTreasureHuntState,
      timetableState: const TimetableState(),
    );
    final withEventCheckIn = repository.eligibility(
      treasureHuntState: completedTreasureHuntState,
      timetableState: const TimetableState(checkedInIds: ['event-1']),
    );

    expect(withoutEventCheckIn.eventCheckInRequired, isTrue);
    expect(withoutEventCheckIn.needsEventCheckIn, isTrue);
    expect(withoutEventCheckIn.canClaimReward, isFalse);
    expect(withEventCheckIn.canClaimReward, isTrue);
  });

  test(
    'allows reward claims without event check-in when the flag is disabled',
    () {
      final repository = buildRepository(rewardRequiresEventCheckIn: false);

      final eligibility = repository.eligibility(
        treasureHuntState: completedTreasureHuntState,
        timetableState: const TimetableState(),
      );

      expect(eligibility.eventCheckInRequired, isFalse);
      expect(eligibility.needsEventCheckIn, isFalse);
      expect(eligibility.canClaimReward, isTrue);
    },
  );
}
