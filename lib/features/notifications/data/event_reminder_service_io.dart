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
  static const _leadTime = Duration(minutes: 30);

  final Box<dynamic> _settingsBox;
  final FlutterLocalNotificationsPlugin _notifications;
  bool _initialized = false;

  EventReminderService({
    required Box<dynamic> settingsBox,
    FlutterLocalNotificationsPlugin? notifications,
  }) : _settingsBox = settingsBox,
       _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  bool get supportsLocalReminders =>
      defaultTargetPlatform != TargetPlatform.fuchsia;

  bool get remindersEnabled =>
      _settingsBox.get(_enabledKey, defaultValue: false) as bool? ?? false;

  Future<void> initialize() async {
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
    );

    _initialized = true;
  }

  Future<bool> enableReminders() async {
    await initialize();
    final granted = await _requestPermissions();
    await _settingsBox.put(_enabledKey, granted);
    return granted;
  }

  Future<void> disableReminders() async {
    await initialize();
    await _notifications.cancelAll();
    await _settingsBox.put(_enabledKey, false);
  }

  Future<void> scheduleFavoriteEventReminders(
    List<TimetableEvent> events,
    Iterable<String> favoriteIds,
  ) async {
    if (!remindersEnabled) return;
    await initialize();

    final favoriteIdSet = favoriteIds.toSet();
    final now = DateTime.now();
    final favoriteEvents = events
        .where((event) => favoriteIdSet.contains(event.id))
        .toList();
    final favoriteNotificationIds = favoriteEvents
        .map((event) => _notificationIdForEvent(event.id))
        .toSet();

    final pending = await _notifications.pendingNotificationRequests();
    for (final notification in pending) {
      if (notification.payload?.startsWith('event:') ?? false) {
        if (!favoriteNotificationIds.contains(notification.id)) {
          await _notifications.cancel(id: notification.id);
        }
      }
    }

    for (final event in favoriteEvents) {
      final scheduledAt = event.startTime.subtract(_leadTime);
      if (!scheduledAt.isAfter(now)) {
        await _notifications.cancel(id: _notificationIdForEvent(event.id));
        continue;
      }

      await _notifications.zonedSchedule(
        id: _notificationIdForEvent(event.id),
        title: event.title,
        body: '${_formatStartTime(event.startTime)} • ${event.location}',
        scheduledDate: timezone.TZDateTime.from(scheduledAt, timezone.local),
        notificationDetails: const NotificationDetails(
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
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'event:${event.id}',
      );
    }
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

  int _notificationIdForEvent(String eventId) {
    var hash = 0;
    for (final codeUnit in eventId.codeUnits) {
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
}
