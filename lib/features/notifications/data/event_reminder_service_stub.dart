import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';

class EventReminderService {
  static const _enabledKey = 'event_reminders_enabled';

  final Box<dynamic> _settingsBox;

  EventReminderService({required Box<dynamic> settingsBox})
    : _settingsBox = settingsBox;

  bool get supportsLocalReminders => false;

  bool get remindersEnabled =>
      _settingsBox.get(_enabledKey, defaultValue: false) as bool? ?? false;

  Duration get reminderLeadTime => const Duration(minutes: 15);

  Future<void> initialize() async {}

  Future<void> dispose() async {}

  Future<bool> enableReminders() async {
    await _settingsBox.put(_enabledKey, false);
    return false;
  }

  Future<void> disableReminders() async {
    await _settingsBox.put(_enabledKey, false);
  }

  Future<void> scheduleFavoriteEventReminders(
    List<TimetableEvent> events,
    Iterable<String> favoriteIds,
  ) async {}

  Duration? reminderDelayFor(TimetableEvent event, {DateTime? now}) {
    final scheduledAt = event.startTime.subtract(reminderLeadTime);
    final reference = now ?? DateTime.now();
    if (!scheduledAt.isAfter(reference)) {
      return null;
    }
    return scheduledAt.difference(reference);
  }
}
