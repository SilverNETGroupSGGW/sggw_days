import 'package:flutter_test/flutter_test.dart';
import 'package:sggw_days/features/rewards/data/models/reward_claim_payload.dart';

void main() {
  test('uses raw device id as reward QR payload', () {
    final payload = RewardClaimPayload(
      deviceId: 'sggw_0123456789abcdef0123456789abcdef',
    );

    expect(payload.toQrData(), payload.deviceId);

    final parsed = RewardClaimPayload.tryParseQrData(payload.toQrData());

    expect(parsed, isNotNull);
    expect(parsed!.deviceId, payload.deviceId);
  });

  test('trims whitespace around scanned device id', () {
    final parsed = RewardClaimPayload.tryParseQrData(
      '  sggw_0123456789abcdef0123456789abcdef  ',
    );

    expect(parsed, isNotNull);
    expect(parsed!.deviceId, 'sggw_0123456789abcdef0123456789abcdef');
  });

  test('rejects malformed reward QR data', () {
    expect(RewardClaimPayload.tryParseQrData('not-a-reward'), isNull);
    expect(RewardClaimPayload.tryParseQrData(''), isNull);
    expect(RewardClaimPayload.tryParseQrData('   '), isNull);
  });
}
