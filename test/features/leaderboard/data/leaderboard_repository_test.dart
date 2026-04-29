import 'package:flutter_test/flutter_test.dart';
import 'package:sggw_days/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

void main() {
  test('calculates overall and treasure-only scores separately', () {
    const points = [
      TreasurePoint(
        id: 'treasure-1',
        name: 'Treasure 1',
        description: 'Description',
        latitude: 52.1,
        longitude: 21.0,
        qrCode: 'qr-1',
        type: PointType.treasurePoint,
      ),
      TreasurePoint(
        id: 'poi-1',
        name: 'POI 1',
        description: 'Description',
        latitude: 52.2,
        longitude: 21.1,
        qrCode: 'qr-2',
        type: PointType.pointOfInterest,
      ),
    ];

    final scores = calculateLeaderboardScores(
      points: points,
      foundPointIds: const ['treasure-1', 'poi-1'],
      checkedInIds: const ['event-1', 'event-2'],
    );

    expect(scores.foundPointScore, 2);
    expect(scores.treasureScore, 1);
    expect(scores.checkInScore, 2);
    expect(scores.totalScore, 4);
  });

  test('sanitizes display names for leaderboard publishing', () {
    expect(sanitizeLeaderboardDisplayName('  Green   Team  '), 'Green Team');
    expect(sanitizeLeaderboardDisplayName(''), '');
    expect(
      sanitizeLeaderboardDisplayName('A very long leaderboard display name'),
      'A very long leaderboard',
    );
  });
}
