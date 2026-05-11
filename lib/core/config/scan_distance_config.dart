import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class ScanDistanceConfig {
  static const parameterName = 'scan_minimal_distance_meters';
  static const fallbackDistanceMeters = 50.0;

  final FirebaseRemoteConfig? _remoteConfig;
  double _distanceMeters = fallbackDistanceMeters;

  ScanDistanceConfig({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  ScanDistanceConfig.fallback() : _remoteConfig = null;

  double get distanceMeters => _distanceMeters;
  bool get isDistanceCheckEnabled => _distanceMeters > 0;

  Future<void> initialize() async {
    final remoteConfig = _remoteConfig;
    if (remoteConfig == null) return;

    try {
      await remoteConfig.setDefaults(const {
        parameterName: fallbackDistanceMeters,
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
    } catch (error) {
      debugPrint('Scan distance config fetch failed: $error');
      _distanceMeters = fallbackDistanceMeters;
    }
  }
}
