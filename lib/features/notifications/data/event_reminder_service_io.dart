import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

class EventReminderService {
  static const _enabledKey = 'event_reminders_enabled';
  static const _channelId = 'event_reminders';
  static const _channelName = 'Event reminders';
  static const _channelDescription = 'Reminders before favourited events start';
  static const _eventPayloadPrefix = 'event:';
  static const _eventPreviewPayloadPrefix = 'event_preview:';
  static const broadcastChannelId = 'event_broadcasts';
  static const _broadcastChannelName = 'Event broadcasts';
  static const _broadcastChannelDescription =
      'Important messages from event organisers';
  static const _leadTime = Duration(minutes: 15);

  final Box<dynamic> _settingsBox;
  final FlutterLocalNotificationsPlugin _notifications;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  final StreamController<String> _selectedEventIdsController =
      StreamController<String>.broadcast();
  bool _initialized = false;
  Future<void>? _initializationFuture;
  Future<void> _notificationOperationQueue = Future<void>.value();

  EventReminderService({
    required Box<dynamic> settingsBox,
    FlutterLocalNotificationsPlugin? notifications,
  }) : _settingsBox = settingsBox,
       _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  bool get supportsLocalReminders =>
      defaultTargetPlatform != TargetPlatform.fuchsia;

  bool get remindersEnabled =>
      _settingsBox.get(_enabledKey, defaultValue: false) as bool? ?? false;

  Stream<String> get selectedEventIds => _selectedEventIdsController.stream;

  Duration get reminderLeadTime => _leadTime;

  Future<void> initialize() async {
    if (_initialized) return;
    final initializationFuture = _initializationFuture;
    if (initializationFuture != null) {
      await initializationFuture;
      return;
    }

    final future = _initializeInternal();
    _initializationFuture = future;
    try {
      await future;
    } finally {
      if (identical(_initializationFuture, future)) {
        _initializationFuture = null;
      }
    }
  }

  Future<void> _initializeInternal() async {
    if (_initialized) return;

    timezone_data.initializeTimeZones();
    timezone.setLocalLocation(timezone.getLocation('Europe/Warsaw'));

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        linux: LinuxInitializationSettings(defaultActionName: 'Open'),
        windows: WindowsInitializationSettings(
          appName: 'Dni SGGW',
          appUserModelId: 'SGGW.DniSGGW.App',
          guid: '4D5068C5-4C8D-4DB9-9C08-B6130EC90E42',
        ),
      ),
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    await _createAndroidChannels();
    await _configureForegroundPushHandling();
    await _deliverLaunchNotificationSelection();

    _initialized = true;
  }

  Future<void> dispose() async {
    await _foregroundMessageSubscription?.cancel();
    await _selectedEventIdsController.close();
  }

  Future<void> _createAndroidChannels() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        broadcastChannelId,
        _broadcastChannelName,
        description: _broadcastChannelDescription,
        importance: Importance.high,
      ),
    );
  }

  Future<void> _configureForegroundPushHandling() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
              alert: true,
              badge: true,
              sound: true,
            );
        return;
      case TargetPlatform.android:
        _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen((
          message,
        ) {
          unawaited(_showForegroundBroadcast(message));
        });
        return;
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return;
    }
  }

  Future<void> _showForegroundBroadcast(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final identifier =
        message.messageId ??
        message.data['broadcastId']?.toString() ??
        '${notification.title}:${notification.body}';

    await _notifications.show(
      id: _notificationIdForKey(identifier),
      title: notification.title ?? 'Dni SGGW',
      body: notification.body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          broadcastChannelId,
          _broadcastChannelName,
          channelDescription: _broadcastChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.message,
        ),
      ),
      payload: message.data['broadcastId'] != null
          ? 'broadcast:${message.data['broadcastId']}'
          : null,
    );
  }

  Future<bool> enableReminders() async {
    await initialize();
    final granted = await _requestPermissions();
    await _settingsBox.put(_enabledKey, granted);
    return granted;
  }

  Future<void> disableReminders() async {
    await _settingsBox.put(_enabledKey, false);
    await _enqueueNotificationOperation(() async {
      await initialize();
      await _cancelEventReminderNotifications(includePreviews: true);
    });
  }

  Future<void> scheduleFavoriteEventReminders(
    List<TimetableEvent> events,
    Iterable<String> favoriteIds,
  ) async {
    await _enqueueNotificationOperation(() async {
      if (!remindersEnabled) return;
      await initialize();

      final favoriteIdSet = favoriteIds.toSet();
      final now = DateTime.now();
      final favoriteEvents = events
          .where((event) => favoriteIdSet.contains(event.id))
          .toList();
      final favoriteNotificationIds = favoriteEvents
          .map((event) => _notificationIdForKey(event.id))
          .toSet();

      final pending = await _notifications.pendingNotificationRequests();
      for (final notification in pending) {
        if ((notification.payload?.startsWith('event:') ?? false) &&
            !favoriteNotificationIds.contains(notification.id)) {
          await _notifications.cancel(id: notification.id);
        }
      }

      for (final event in favoriteEvents) {
        final scheduledAt = event.startTime.subtract(_leadTime);
        if (!scheduledAt.isAfter(now)) {
          await _notifications.cancel(id: _notificationIdForKey(event.id));
          continue;
        }

        await _notifications.zonedSchedule(
          id: _notificationIdForKey(event.id),
          title: event.title,
          body: _eventNotificationBody(event),
          scheduledDate: timezone.TZDateTime.from(scheduledAt, timezone.local),
          notificationDetails: _eventNotificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: '$_eventPayloadPrefix${event.id}',
        );
      }
    });
  }

  Future<bool> showEventPreview(TimetableEvent event) async {
    if (!supportsLocalReminders) return false;

    return _enqueueNotificationOperation(() async {
      await initialize();
      final granted = await _requestPermissions();
      if (!granted) {
        return false;
      }

      await _notifications.show(
        id: _notificationIdForKey(_eventPreviewKey(event)),
        title: event.title,
        body: _eventNotificationBody(event),
        notificationDetails: _eventNotificationDetails,
        payload: '$_eventPreviewPayloadPrefix${event.id}',
      );
      return true;
    });
  }

  Duration? reminderDelayFor(TimetableEvent event, {DateTime? now}) {
    final scheduledAt = event.startTime.subtract(_leadTime);
    final reference = now ?? DateTime.now();
    if (!scheduledAt.isAfter(reference)) {
      return null;
    }
    return scheduledAt.difference(reference);
  }

  Future<bool> _requestPermissions() async {
    final androidGranted = await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    if (androidGranted != null) return androidGranted;

    final iosGranted = await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    if (iosGranted != null) return iosGranted;

    final macosGranted = await _notifications
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return macosGranted ?? true;
  }

  NotificationDetails get _eventNotificationDetails =>
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.event,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        linux: LinuxNotificationDetails(),
        windows: WindowsNotificationDetails(),
      );

  Future<void> _cancelEventReminderNotifications({
    bool includePreviews = false,
  }) async {
    final pending = await _notifications.pendingNotificationRequests();
    for (final notification in pending) {
      final payload = notification.payload;
      final isEventReminder = payload?.startsWith('event:') ?? false;
      final isPreview = payload?.startsWith('event_preview:') ?? false;
      if (isEventReminder || (includePreviews && isPreview)) {
        await _notifications.cancel(id: notification.id);
      }
    }
  }

  Future<void> _deliverLaunchNotificationSelection() async {
    final launchDetails = await _notifications
        .getNotificationAppLaunchDetails();
    if (!(launchDetails?.didNotificationLaunchApp ?? false)) {
      return;
    }

    _emitSelectedEventId(launchDetails?.notificationResponse?.payload);
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    _emitSelectedEventId(response.payload);
  }

  void _emitSelectedEventId(String? payload) {
    final eventId = eventIdFromPayload(payload);
    if (eventId == null || _selectedEventIdsController.isClosed) {
      return;
    }

    _selectedEventIdsController.add(eventId);
  }

  Future<T> _enqueueNotificationOperation<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _notificationOperationQueue = _notificationOperationQueue
        .catchError((_) {})
        .then((_) async {
          try {
            completer.complete(await operation());
          } catch (error, stackTrace) {
            completer.completeError(error, stackTrace);
          }
        });
    return completer.future;
  }

  int _notificationIdForKey(String key) {
    var hash = 0;
    for (final codeUnit in key.codeUnits) {
      hash = 0x1fffffff & (hash + codeUnit);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= hash >> 11;
    hash = 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
    return hash;
  }

  String _formatStartTime(DateTime startTime) {
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _eventNotificationBody(TimetableEvent event) {
    return '${_formatStartTime(event.startTime)} • ${event.location}';
  }

  @visibleForTesting
  static String? eventIdFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }

    for (final prefix in [_eventPayloadPrefix, _eventPreviewPayloadPrefix]) {
      if (!payload.startsWith(prefix)) {
        continue;
      }

      final eventId = payload.substring(prefix.length);
      return eventId.isEmpty ? null : eventId;
    }

    return null;
  }

  String _eventPreviewKey(TimetableEvent event) {
    if (event.id.isNotEmpty) {
      return 'preview:${event.id}';
    }
    return 'preview:${event.title}:${event.startTime.toIso8601String()}';
  }
}
