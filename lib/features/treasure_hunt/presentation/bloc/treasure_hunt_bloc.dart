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

      emit(
        state.copyWith(
          status: TreasureHuntStatus.success,
          points: points,
          foundPointIds: foundIds,
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

    emit(
      state.copyWith(
        foundPointIds: updatedFoundIds,
      ),
    );
  }

  Future<void> _onScanQRCode(
    ScanQRCode event,
    Emitter<TreasureHuntState> emit,
  ) async {
    final point = state.points
        .where((p) => p.qrCode == event.qrCode)
        .firstOrNull;

    if (point != null) {
      add(MarkPointAsFound(point.id));
    }
  }
}
