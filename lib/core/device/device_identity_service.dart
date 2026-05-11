import 'dart:convert';
import 'dart:math';

import 'package:android_id/android_id.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';

class DeviceIdentityService {
  static const _deviceIdKey = 'reward_device_id';
  static const _secureStorage = FlutterSecureStorage();
  static const _androidIdPlugin = AndroidId();

  final Box<dynamic> _settingsBox;
  final DeviceInfoPlugin _deviceInfo;

  DeviceIdentityService({
    required Box<dynamic> settingsBox,
    DeviceInfoPlugin? deviceInfo,
  }) : _settingsBox = settingsBox,
       _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  Future<String> deviceId() async {
    final existing = _settingsBox.get(_deviceIdKey) as String?;
    if (existing != null && existing.isNotEmpty) return existing;

    final secureExisting = await _readSecureDeviceId();
    if (secureExisting != null && secureExisting.isNotEmpty) {
      await _settingsBox.put(_deviceIdKey, secureExisting);
      return secureExisting;
    }

    final platformId = await _platformBackedId();
    final id = platformId ?? _randomDeviceId();
    await _settingsBox.put(_deviceIdKey, id);
    await _writeSecureDeviceId(id);
    return id;
  }

  Future<String?> _readSecureDeviceId() async {
    try {
      return await _secureStorage.read(key: _deviceIdKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeSecureDeviceId(String id) async {
    try {
      await _secureStorage.write(key: _deviceIdKey, value: id);
    } catch (_) {}
  }

  Future<String?> _platformBackedId() async {
    try {
      if (kIsWeb) return null;

      return switch (defaultTargetPlatform) {
        TargetPlatform.android => _androidDeviceId(),
        TargetPlatform.iOS => _iosId(),
        TargetPlatform.macOS => _macOsId(),
        TargetPlatform.linux => _linuxId(),
        TargetPlatform.windows => _windowsId(),
        TargetPlatform.fuchsia => null,
      };
    } catch (_) {
      return null;
    }
  }

  Future<String?> _androidDeviceId() async {
    final androidId = await _androidIdPlugin.getId();
    return _hashStableParts(['android', androidId]);
  }

  Future<String?> _iosId() async {
    final info = await _deviceInfo.iosInfo;
    return _hashStableParts(['ios', info.identifierForVendor]);
  }

  Future<String?> _macOsId() async {
    final info = await _deviceInfo.macOsInfo;
    return _hashStableParts(['macos', info.systemGUID]);
  }

  Future<String?> _linuxId() async {
    final info = await _deviceInfo.linuxInfo;
    return _hashStableParts(['linux', info.machineId]);
  }

  Future<String?> _windowsId() async {
    final info = await _deviceInfo.windowsInfo;
    return _hashStableParts(['windows', info.deviceId]);
  }

  String? _hashStableParts(List<String?> parts) {
    final normalized = parts
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (normalized.length < 2) return null;

    final digest = sha256.convert(utf8.encode(normalized.join('|'))).toString();
    return 'sggw_${digest.substring(0, 32)}';
  }

  String _randomDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final id = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return 'sggw_$id';
  }
}
