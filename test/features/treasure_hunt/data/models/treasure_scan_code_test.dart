import 'package:flutter_test/flutter_test.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_scan_code.dart';

void main() {
  group('tryExtractTreasurePointId', () {
    test('extracts a point id from an HTTPS scan URL', () {
      expect(
        tryExtractTreasurePointId('https://sggw-days.web.app/scan/point_123'),
        'point_123',
      );
    });

    test('extracts a point id from a relative scan path', () {
      expect(tryExtractTreasurePointId('/scan/point-123'), 'point-123');
    });

    test('rejects insecure or malformed scan payloads', () {
      expect(
        tryExtractTreasurePointId('http://sggw-days.web.app/scan/point-123'),
        isNull,
      );
      expect(
        tryExtractTreasurePointId('https://sggw-days.web.app/scan/../../admin'),
        isNull,
      );
      expect(tryExtractTreasurePointId('not-a-scan-code'), isNull);
      expect(isValidTreasurePointId('../admin'), isFalse);
    });
  });
}
