import 'package:flutter_test/flutter_test.dart';
import 'package:sggw_days/features/rewards/data/models/reward_claim_payload.dart';

void main() {
  test('round-trips reward QR payload data', () {
    final payload = RewardClaimPayload(
      deviceId: 'sggw_0123456789abcdef0123456789abcdef',
      generatedAt: DateTime.utc(2026, 5, 20, 12),
      treasureScans: [
        RewardScanRecord(
          id: 'treasure-1',
          scannedAt: DateTime.utc(2026, 5, 20, 10),
        ),
        RewardScanRecord(
          id: 'treasure-2',
          scannedAt: DateTime.utc(2026, 5, 20, 11),
        ),
      ],
      eventCheckIns: [
        RewardScanRecord(
          id: 'event-1',
          scannedAt: DateTime.utc(2026, 5, 20, 11, 30),
        ),
      ],
    );

    final parsed = RewardClaimPayload.tryParseQrData(payload.toQrData());

    expect(parsed, isNotNull);
    expect(parsed!.deviceId, payload.deviceId);
    expect(parsed.payloadHash, payload.payloadHash);
    expect(parsed.treasureScans.map((record) => record.id), [
      'treasure-1',
      'treasure-2',
    ]);
    expect(parsed.eventCheckIns.single.id, 'event-1');
    expect(parsed.completedAt, DateTime.utc(2026, 5, 20, 11, 30));
  });

  test('rejects malformed reward QR data', () {
    expect(RewardClaimPayload.tryParseQrData('not-a-reward'), isNull);
    expect(
      RewardClaimPayload.tryParseQrData('${RewardClaimPayload.qrPrefix}bad'),
      isNull,
    );
  });
}
