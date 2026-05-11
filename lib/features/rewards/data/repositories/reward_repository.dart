import 'package:hive_ce/hive.dart';
import 'package:sggw_days/core/device/device_identity_service.dart';
import 'package:sggw_days/features/rewards/data/models/reward_claim_payload.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_state.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';

class RewardEligibility {
  final bool treasureComplete;
  final bool hasEventCheckIn;
  final int scannedTreasureCount;
  final int totalTreasureCount;

  const RewardEligibility({
    required this.treasureComplete,
    required this.hasEventCheckIn,
    required this.scannedTreasureCount,
    required this.totalTreasureCount,
  });

  bool get canClaimReward => treasureComplete && hasEventCheckIn;
}

class RewardRepository {
  final DeviceIdentityService _deviceIdentityService;

  RewardRepository({required DeviceIdentityService deviceIdentityService})
    : _deviceIdentityService = deviceIdentityService;

  RewardEligibility eligibility({
    required TreasureHuntState treasureHuntState,
    required TimetableState timetableState,
  }) {
    final treasurePoints = treasureHuntState.sortedTreasurePoints;
    final foundIds = treasureHuntState.foundPointIds.toSet();
    final scannedTreasureCount = treasurePoints
        .where((point) => foundIds.contains(point.id))
        .length;
    return RewardEligibility(
      treasureComplete:
          treasurePoints.isNotEmpty &&
          scannedTreasureCount == treasurePoints.length,
      hasEventCheckIn: timetableState.checkedInIds.isNotEmpty,
      scannedTreasureCount: scannedTreasureCount,
      totalTreasureCount: treasurePoints.length,
    );
  }

  Future<RewardClaimPayload> buildClaimPayload({
    required TreasureHuntState treasureHuntState,
    required TimetableState timetableState,
  }) async {
    final deviceId = await _deviceIdentityService.deviceId();
    final treasureIds = treasureHuntState.sortedTreasurePoints
        .map((point) => point.id)
        .toSet();
    final treasureScans =
        treasureHuntState.scanHistory.entries
            .where((entry) => treasureIds.contains(entry.key))
            .map(
              (entry) =>
                  RewardScanRecord(id: entry.key, scannedAt: entry.value),
            )
            .toList()
          ..sort((a, b) => a.scannedAt.compareTo(b.scannedAt));
    final eventCheckIns =
        timetableState.checkedInHistory.entries
            .map(
              (entry) =>
                  RewardScanRecord(id: entry.key, scannedAt: entry.value),
            )
            .toList()
          ..sort((a, b) => a.scannedAt.compareTo(b.scannedAt));

    return RewardClaimPayload(
      deviceId: deviceId,
      generatedAt: DateTime.now(),
      treasureScans: treasureScans,
      eventCheckIns: eventCheckIns,
    );
  }
}

Future<Map<String, DateTime>> loadEventCheckInHistoryFromHive() async {
  final historyBox = await Hive.openBox('event_check_in_history');
  final history = <String, DateTime>{};
  for (final key in historyBox.keys) {
    final value = historyBox.get(key);
    if (key is String && value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) history[key] = parsed;
    }
  }
  return history;
}
