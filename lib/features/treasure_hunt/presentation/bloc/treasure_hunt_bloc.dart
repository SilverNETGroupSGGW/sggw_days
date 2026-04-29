import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_scan_code.dart';
import 'package:sggw_days/features/treasure_hunt/data/repositories/treasure_hunt_repository.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_event.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';

class TreasureHuntBloc extends Bloc<TreasureHuntEvent, TreasureHuntState> {
  final TreasureHuntRepository _repository;
  final Box<List<String>> _progressBox;
  StreamSubscription<List<TreasurePoint>>? _pointsSubscription;

  TreasureHuntBloc({
    required TreasureHuntRepository repository,
    required Box<List<String>> progressBox,
  }) : _repository = repository,
       _progressBox = progressBox,
       super(const TreasureHuntState()) {
    on<LoadTreasurePoints>(_onLoadTreasurePoints);
    on<MarkPointAsFound>(_onMarkPointAsFound);
    on<ScanQRCode>(_onScanQRCode);
    on<TrackPoint>(_onTrackPoint);
    on<_TreasurePointsUpdated>(_onTreasurePointsUpdated);
    on<_TreasurePointsFailed>(_onTreasurePointsFailed);
  }

  Future<void> _onLoadTreasurePoints(
    LoadTreasurePoints event,
    Emitter<TreasureHuntState> emit,
  ) async {
    emit(state.copyWith(status: TreasureHuntStatus.loading));
    try {
      await _pointsSubscription?.cancel();
      final (:foundIds, :history) = await _loadLocalProgress();

      emit(state.copyWith(foundPointIds: foundIds, scanHistory: history));

      _pointsSubscription = _repository.watchTreasurePoints().listen(
        (points) => add(_TreasurePointsUpdated(points)),
        onError: (Object error) => add(_TreasurePointsFailed(error.toString())),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TreasureHuntStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<({List<String> foundIds, Map<String, DateTime> history})>
  _loadLocalProgress() async {
    final foundIds =
        _progressBox.get('found_points', defaultValue: <String>[]) ??
        <String>[];

    final historyBox = await Hive.openBox('scan_history');
    final history = <String, DateTime>{};
    for (final id in foundIds) {
      final timestamp = historyBox.get(id);
      if (timestamp != null) {
        history[id] = DateTime.parse(timestamp as String);
      }
    }

    return (foundIds: foundIds, history: history);
  }

  void _onTreasurePointsUpdated(
    _TreasurePointsUpdated event,
    Emitter<TreasureHuntState> emit,
  ) {
    emit(
      state.copyWith(status: TreasureHuntStatus.success, points: event.points),
    );
  }

  void _onTreasurePointsFailed(
    _TreasurePointsFailed event,
    Emitter<TreasureHuntState> emit,
  ) {
    emit(
      state.copyWith(
        status: state.points.isEmpty
            ? TreasureHuntStatus.error
            : TreasureHuntStatus.success,
        errorMessage: event.message,
      ),
    );
  }

  Future<void> _onMarkPointAsFound(
    MarkPointAsFound event,
    Emitter<TreasureHuntState> emit,
  ) async {
    if (state.foundPointIds.contains(event.pointId)) {
      return;
    }

    final updatedFoundIds = [...state.foundPointIds, event.pointId];
    await _progressBox.put('found_points', updatedFoundIds);

    // Save scan timestamp
    final now = DateTime.now();
    final historyBox = await Hive.openBox('scan_history');
    await historyBox.put(event.pointId, now.toIso8601String());

    final updatedHistory = Map<String, DateTime>.from(state.scanHistory);
    updatedHistory[event.pointId] = now;

    emit(
      state.copyWith(
        foundPointIds: updatedFoundIds,
        scanHistory: updatedHistory,
        lastScannedPointId: event.pointId,
      ),
    );
  }

  void _onTrackPoint(TrackPoint event, Emitter<TreasureHuntState> emit) {
    emit(state.copyWith(trackedPointId: event.pointId));
  }

  Future<void> _onScanQRCode(
    ScanQRCode event,
    Emitter<TreasureHuntState> emit,
  ) async {
    final pointId = tryExtractTreasurePointId(event.qrCode);

    final point = pointId != null
        ? state.points.where((p) => p.id == pointId).firstOrNull
        : state.points.where((p) => p.qrCode == event.qrCode).firstOrNull;

    if (point != null && state.unlockedPointIds.contains(point.id)) {
      add(MarkPointAsFound(point.id));
    }
  }

  @override
  Future<void> close() async {
    await _pointsSubscription?.cancel();
    return super.close();
  }
}

class _TreasurePointsUpdated extends TreasureHuntEvent {
  final List<TreasurePoint> points;

  const _TreasurePointsUpdated(this.points);

  @override
  List<Object?> get props => [points];
}

class _TreasurePointsFailed extends TreasureHuntEvent {
  final String message;

  const _TreasurePointsFailed(this.message);

  @override
  List<Object?> get props => [message];
}
