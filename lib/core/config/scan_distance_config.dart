import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class ScanDistanceConfig {
  static const parameterName = 'scan_minimal_distance_meters';
  static const rewardRequiresEventCheckInParameterName =
      'reward_requires_event_check_in';
  static const fallbackDistanceMeters = 50.0;
  static const fallbackRewardRequiresEventCheckIn = true;

  final FirebaseRemoteConfig? _remoteConfig;
  double _distanceMeters;
  bool _rewardRequiresEventCheckIn;

  ScanDistanceConfig({
    FirebaseRemoteConfig? remoteConfig,
    double distanceMeters = fallbackDistanceMeters,
    bool rewardRequiresEventCheckIn = fallbackRewardRequiresEventCheckIn,
  }) : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance,
       _distanceMeters = distanceMeters,
       _rewardRequiresEventCheckIn = rewardRequiresEventCheckIn;

  ScanDistanceConfig.fallback({
    double distanceMeters = fallbackDistanceMeters,
    bool rewardRequiresEventCheckIn = fallbackRewardRequiresEventCheckIn,
  }) : _remoteConfig = null,
       _distanceMeters = distanceMeters,
       _rewardRequiresEventCheckIn = rewardRequiresEventCheckIn;

  double get distanceMeters => _distanceMeters;
  bool get isDistanceCheckEnabled => _distanceMeters > 0;
  bool get rewardRequiresEventCheckIn => _rewardRequiresEventCheckIn;

  Future<void> initialize() async {
    final remoteConfig = _remoteConfig;
    if (remoteConfig == null) return;

    try {
      await remoteConfig.setDefaults(const {
        parameterName: fallbackDistanceMeters,
        rewardRequiresEventCheckInParameterName:
            fallbackRewardRequiresEventCheckIn,
      });
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(minutes: 30),
        ),
      );
      await remoteConfig.fetchAndActivate();
      _distanceMeters = remoteConfig.getDouble(parameterName);
      _rewardRequiresEventCheckIn = remoteConfig.getBool(
        rewardRequiresEventCheckInParameterName,
      );
    } catch (error) {
      debugPrint('Scan distance config fetch failed: $error');
      _distanceMeters = fallbackDistanceMeters;
      _rewardRequiresEventCheckIn = fallbackRewardRequiresEventCheckIn;
    }
  }
}
