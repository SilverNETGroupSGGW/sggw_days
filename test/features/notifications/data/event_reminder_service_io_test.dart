import 'package:flutter_test/flutter_test.dart';
import 'package:sggw_days/features/notifications/data/event_reminder_service_io.dart';

void main() {
  group('EventReminderService.eventIdFromPayload', () {
    test('parses scheduled event payloads', () {
      expect(
        EventReminderService.eventIdFromPayload('event:event-123'),
        'event-123',
      );
    });

    test('parses preview event payloads', () {
      expect(
        EventReminderService.eventIdFromPayload('event_preview:event-456'),
        'event-456',
      );
    });

    test('ignores non-event payloads and empty values', () {
      expect(EventReminderService.eventIdFromPayload(null), isNull);
      expect(EventReminderService.eventIdFromPayload(''), isNull);
      expect(EventReminderService.eventIdFromPayload('broadcast:test'), isNull);
      expect(EventReminderService.eventIdFromPayload('event:'), isNull);
    });
  });
}
