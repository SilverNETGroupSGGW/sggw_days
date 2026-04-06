import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/treasure_hunt/data/repositories/treasure_hunt_repository.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_event.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';

class TreasureHuntBloc extends Bloc<TreasureHuntEvent, TreasureHuntState> {
  final TreasureHuntRepository _repository;
  final Box<List<String>> _progressBox;

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
  }

  Future<void> _onLoadTreasurePoints(
    LoadTreasurePoints event,
    Emitter<TreasureHuntState> emit,
  ) async {
    emit(state.copyWith(status: TreasureHuntStatus.loading));
    try {
      final points = await _repository.getTreasurePoints();
      final foundIds =
          _progressBox.get('found_points', defaultValue: <String>[]) ??
          <String>[];

      // Load scan history
      final historyBox = await Hive.openBox('scan_history');
      final Map<String, DateTime> history = {};
      for (final id in foundIds) {
        final timestamp = historyBox.get(id);
        if (timestamp != null) {
          history[id] = DateTime.parse(timestamp as String);
        }
      }

      emit(
        state.copyWith(
          status: TreasureHuntStatus.success,
          points: points,
          foundPointIds: foundIds,
          scanHistory: history,
        ),
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
    // Try matching by URL-based point ID first
    final uri = Uri.tryParse(event.qrCode);
    String? pointId;
    if (uri != null &&
        uri.pathSegments.length == 2 &&
        uri.pathSegments[0] == 'scan') {
      pointId = uri.pathSegments[1];
    }

    final point = pointId != null
        ? state.points.where((p) => p.id == pointId).firstOrNull
        : state.points.where((p) => p.qrCode == event.qrCode).firstOrNull;

    if (point != null) {
      add(MarkPointAsFound(point.id));
    }
  }
}
