import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/core/config/scan_distance_config.dart';
import 'package:sggw_days/core/device/device_identity_service.dart';
import 'package:sggw_days/features/rewards/data/models/reward_claim_payload.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_state.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';

class RewardEligibility {
  final bool treasureComplete;
  final bool hasEventCheckIn;
  final bool eventCheckInRequired;
  final int scannedTreasureCount;
  final int totalTreasureCount;

  const RewardEligibility({
    required this.treasureComplete,
    required this.hasEventCheckIn,
    required this.eventCheckInRequired,
    required this.scannedTreasureCount,
    required this.totalTreasureCount,
  });

  bool get isEventCheckInSatisfied => hasEventCheckIn || !eventCheckInRequired;

  bool get needsEventCheckIn =>
      treasureComplete && eventCheckInRequired && !hasEventCheckIn;

  bool get canClaimReward => treasureComplete && isEventCheckInSatisfied;
}

class RewardRepository {
  final DeviceIdentityService _deviceIdentityService;
  final ScanDistanceConfig _scanDistanceConfig;
  final FirebaseFirestore? _firestore;

  RewardRepository({
    required DeviceIdentityService deviceIdentityService,
    required ScanDistanceConfig scanDistanceConfig,
    FirebaseFirestore? firestore,
  }) : _deviceIdentityService = deviceIdentityService,
       _scanDistanceConfig = scanDistanceConfig,
       _firestore = firestore;

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
      eventCheckInRequired: _scanDistanceConfig.rewardRequiresEventCheckIn,
      scannedTreasureCount: scannedTreasureCount,
      totalTreasureCount: treasurePoints.length,
    );
  }

  Future<RewardClaimPayload> buildClaimPayload() async {
    final deviceId = await _deviceIdentityService.deviceId();
    return RewardClaimPayload(deviceId: deviceId);
  }

  Future<bool> isRewardReceived() async {
    try {
      final deviceId = await _deviceIdentityService.deviceId();
      final snapshot = await (_firestore ?? FirebaseFirestore.instance)
          .collection('reward_claim_status')
          .doc(deviceId)
          .get();
      return snapshot.exists && snapshot.data()?['status'] == 'received';
    } on FirebaseException catch (error) {
      debugPrint('Reward status check failed: $error');
      return false;
    } catch (error) {
      debugPrint('Reward status check failed: $error');
      return false;
    }
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
