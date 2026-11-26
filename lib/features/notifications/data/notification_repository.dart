import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

class NotificationRegistrationResult {
  final bool enabled;
  final String? message;

  const NotificationRegistrationResult({required this.enabled, this.message});
}

class NotificationRepository {
  static const _pushEnabledKey = 'push_notifications_enabled';
  static const _installationIdKey = 'notification_installation_id';
  static const _webVapidKey = String.fromEnvironment(
    'FIREBASE_WEB_PUSH_VAPID_KEY',
    defaultValue:
        'BKJG3XNhTnltmW5iQqRus0TGlJ2KJEuQkSExGDcaJByV19-Sx7Wi8ycAIb0vW36gF7xtEODQaFfOeai2W69up1I',
  );

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final Box<dynamic> _settingsBox;
  Future<void> _tokenWriteQueue = Future<void>.value();
  StreamSubscription<String>? _tokenRefreshSubscription;

  NotificationRepository({
    required Box<dynamic> settingsBox,
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  }) : _settingsBox = settingsBox,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _messaging = messaging ?? FirebaseMessaging.instance;

  bool get pushNotificationsEnabled =>
      _settingsBox.get(_pushEnabledKey, defaultValue: false) as bool? ?? false;

  void startTokenRefreshListener() {
    _tokenRefreshSubscription ??= _messaging.onTokenRefresh.listen((token) {
      if (!pushNotificationsEnabled) return;
      unawaited(_saveTokenQueued(token, enabled: true));
    });
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
  }

  Future<NotificationRegistrationResult> enablePushNotifications() async {
    final permission = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (permission.authorizationStatus == AuthorizationStatus.denied) {
      await _settingsBox.put(_pushEnabledKey, false);
      return const NotificationRegistrationResult(
        enabled: false,
        message: 'Permission denied',
      );
    }

    final token = await _resolveToken();
    if (token == null || token.isEmpty) {
      await _settingsBox.put(_pushEnabledKey, false);
      return const NotificationRegistrationResult(
        enabled: false,
        message: 'Push token unavailable on this device',
      );
    }

    await _settingsBox.put(_pushEnabledKey, true);
    await _saveTokenQueued(token, enabled: true);
    return const NotificationRegistrationResult(enabled: true);
  }

  Future<void> disablePushNotifications() async {
    await _settingsBox.put(_pushEnabledKey, false);
    final token = await _resolveToken(silent: true);
    if (token != null && token.isNotEmpty) {
      await _saveTokenQueued(token, enabled: false);
    }
  }

  Future<void> refreshRegistrationIfEnabled() async {
    startTokenRefreshListener();
    if (!pushNotificationsEnabled) return;
    final token = await _resolveToken(silent: true);
    if (token == null || token.isEmpty) return;
    await _saveTokenQueued(token, enabled: true);
  }

  Future<String?> _resolveToken({bool silent = false}) async {
    try {
      if (kIsWeb) {
        if (_webVapidKey.isEmpty) return null;
        return await _messaging.getToken(vapidKey: _webVapidKey);
      }
      return await _messaging.getToken();
    } catch (error) {
      if (silent) return null;
      rethrow;
    }
  }

  Future<void> _saveTokenQueued(String token, {required bool enabled}) async {
    final write = _tokenWriteQueue.catchError((_) {}).then((_) async {
      try {
        await _saveToken(token, enabled: enabled);
      } on FirebaseException catch (error) {
        debugPrint('Notification token sync failed: ${error.code}');
      } catch (error) {
        debugPrint('Notification token sync failed: $error');
      }
    });
    _tokenWriteQueue = write;
    await write;
  }

  Future<void> _saveToken(String token, {required bool enabled}) async {
    final installationId = await _installationId();
    await _firestore.collection('notification_tokens').doc(installationId).set({
      'installationId': installationId,
      'token': token,
      'platform': _platformLabel(),
      'enabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _installationId() async {
    final existing = _settingsBox.get(_installationIdKey) as String?;
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final id = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    await _settingsBox.put(_installationIdKey, id);
    return id;
  }

  String _platformLabel() {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.linux => 'linux',
      TargetPlatform.windows => 'windows',
      TargetPlatform.fuchsia => 'unknown',
    };
  }
}
