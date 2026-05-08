import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/data/repositories/treasure_hunt_repository.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_event.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';

class _FakeTreasureHuntRepository extends TreasureHuntRepository {
  _FakeTreasureHuntRepository(this.points);

  final List<TreasurePoint> points;

  @override
  Future<List<TreasurePoint>> getTreasurePoints() async => points;

  @override
  Stream<List<TreasurePoint>> watchTreasurePoints() => Stream.value(points);
}

class _StreamingTreasureHuntRepository extends TreasureHuntRepository {
  final StreamController<List<TreasurePoint>> controller =
      StreamController<List<TreasurePoint>>();

  @override
  Future<List<TreasurePoint>> getTreasurePoints() async => const [];

  @override
  Stream<List<TreasurePoint>> watchTreasurePoints() => controller.stream;
}

class _SeededTreasureHuntBloc extends TreasureHuntBloc {
  _SeededTreasureHuntBloc({
    required super.repository,
    required super.progressBox,
    required List<TreasurePoint> points,
  }) {
    emit(TreasureHuntState(status: TreasureHuntStatus.success, points: points));
  }
}

void main() {
  late Directory tempDirectory;

  setUpAll(() {
    tempDirectory = Directory.systemTemp.createTempSync(
      'sggw_days_treasure_hunt_bloc_test_',
    );
    Hive.init(tempDirectory.path);
  });

  tearDown(() async {
    if (Hive.isBoxOpen('progress_bloc_test')) {
      await Hive.box<List<String>>('progress_bloc_test').close();
    }
    if (Hive.isBoxOpen('scan_history')) {
      await Hive.box('scan_history').close();
    }
    await Hive.deleteBoxFromDisk('progress_bloc_test');
    await Hive.deleteBoxFromDisk('scan_history');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test('ignores scans for locked treasure points', () async {
    const firstPoint = TreasurePoint(
      id: 'point-1',
      name: 'First Point',
      description: 'First description',
      latitude: 52.1598,
      longitude: 21.0463,
      qrCode: 'https://sggw-days.web.app/scan/point-1',
      type: PointType.treasurePoint,
      order: 0,
    );
    const secondPoint = TreasurePoint(
      id: 'point-2',
      name: 'Second Point',
      description: 'Second description',
      latitude: 52.16,
      longitude: 21.0465,
      qrCode: 'https://sggw-days.web.app/scan/point-2',
      type: PointType.treasurePoint,
      order: 1,
    );
    final progressBox = await Hive.openBox<List<String>>('progress_bloc_test');
    final bloc = _SeededTreasureHuntBloc(
      repository: _FakeTreasureHuntRepository(const [firstPoint, secondPoint]),
      progressBox: progressBox,
      points: const [firstPoint, secondPoint],
    );

    bloc.add(const ScanQRCode('https://sggw-days.web.app/scan/point-2'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(bloc.state.foundPointIds, isEmpty);
    expect(progressBox.get('found_points'), isNull);

    await bloc.close();
  });

  test('marks scans for unlocked treasure points as found', () async {
    const firstPoint = TreasurePoint(
      id: 'point-1',
      name: 'First Point',
      description: 'First description',
      latitude: 52.1598,
      longitude: 21.0463,
      qrCode: 'https://sggw-days.web.app/scan/point-1',
      type: PointType.treasurePoint,
      order: 0,
    );
    const secondPoint = TreasurePoint(
      id: 'point-2',
      name: 'Second Point',
      description: 'Second description',
      latitude: 52.16,
      longitude: 21.0465,
      qrCode: 'https://sggw-days.web.app/scan/point-2',
      type: PointType.treasurePoint,
      order: 1,
    );
    final progressBox = await Hive.openBox<List<String>>('progress_bloc_test');
    final bloc = _SeededTreasureHuntBloc(
      repository: _FakeTreasureHuntRepository(const [firstPoint, secondPoint]),
      progressBox: progressBox,
      points: const [firstPoint, secondPoint],
    );

    final firstScanCompleted = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TreasureHuntState>().having(
          (state) => state.foundPointIds,
          'foundPointIds',
          equals(const ['point-1']),
        ),
      ),
    );
    bloc.add(const ScanQRCode('https://sggw-days.web.app/scan/point-1'));
    await firstScanCompleted;
    expect(bloc.state.foundPointIds, equals(const ['point-1']));

    final secondScanCompleted = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TreasureHuntState>().having(
          (state) => state.foundPointIds,
          'foundPointIds',
          equals(const ['point-1', 'point-2']),
        ),
      ),
    );
    bloc.add(const ScanQRCode('https://sggw-days.web.app/scan/point-2'));
    await secondScanCompleted;

    expect(bloc.state.foundPointIds, equals(const ['point-1', 'point-2']));
    expect(
      progressBox.get('found_points'),
      equals(const ['point-1', 'point-2']),
    );

    await bloc.close();
  });

  test('updates points when repository emits a new snapshot', () async {
    const firstPoint = TreasurePoint(
      id: 'point-1',
      name: 'First Point',
      description: 'First description',
      latitude: 52.1598,
      longitude: 21.0463,
      qrCode: 'https://sggw-days.web.app/scan/point-1',
      type: PointType.treasurePoint,
      order: 0,
    );
    const renamedPoint = TreasurePoint(
      id: 'point-1',
      name: 'Updated Point',
      description: 'Fresh description',
      latitude: 52.1598,
      longitude: 21.0463,
      qrCode: 'https://sggw-days.web.app/scan/point-1',
      type: PointType.treasurePoint,
      order: 0,
    );

    final progressBox = await Hive.openBox<List<String>>('progress_bloc_test');
    final repository = _StreamingTreasureHuntRepository();
    final bloc = TreasureHuntBloc(
      repository: repository,
      progressBox: progressBox,
    );

    final firstSnapshot = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TreasureHuntState>().having(
          (state) => state.points.single.name,
          'point name',
          'First Point',
        ),
      ),
    );
    bloc.add(const LoadTreasurePoints());
    repository.controller.add(const [firstPoint]);
    await firstSnapshot;

    final updatedSnapshot = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TreasureHuntState>().having(
          (state) => state.points.single.name,
          'point name',
          'Updated Point',
        ),
      ),
    );
    repository.controller.add(const [renamedPoint]);
    await updatedSnapshot;

    await bloc.close();
    await repository.controller.close();
  });

  test('shows feedback when a point is scanned twice', () async {
    const firstPoint = TreasurePoint(
      id: 'point-1',
      name: 'First Point',
      description: 'First description',
      latitude: 52.1598,
      longitude: 21.0463,
      qrCode: 'https://sggw-days.web.app/scan/point-1',
      type: PointType.treasurePoint,
      order: 0,
    );
    final progressBox = await Hive.openBox<List<String>>('progress_bloc_test');
    final bloc = _SeededTreasureHuntBloc(
      repository: _FakeTreasureHuntRepository(const [firstPoint]),
      progressBox: progressBox,
      points: const [firstPoint],
    );

    final firstScanCompleted = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TreasureHuntState>().having(
          (state) => state.lastScannedPointId,
          'lastScannedPointId',
          'point-1',
        ),
      ),
    );
    bloc.add(const ScanQRCode('https://sggw-days.web.app/scan/point-1'));
    await firstScanCompleted;

    final duplicateScanFeedback = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TreasureHuntState>()
            .having(
              (state) => state.scanFeedback,
              'scanFeedback',
              TreasureHuntScanFeedback.alreadyScanned,
            )
            .having(
              (state) => state.foundPointIds,
              'foundPointIds',
              equals(const ['point-1']),
            ),
      ),
    );
    bloc.add(const ScanQRCode('https://sggw-days.web.app/scan/point-1'));
    await duplicateScanFeedback;

    expect(bloc.state.foundPointIds, equals(const ['point-1']));

    await bloc.close();
  });
}
