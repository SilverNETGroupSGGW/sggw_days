import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:sggw_days/features/leaderboard/presentation/bloc/leaderboard_event.dart';
import 'package:sggw_days/features/leaderboard/presentation/bloc/leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository _repository;
  StreamSubscription? _overallSubscription;
  StreamSubscription? _treasureSubscription;
  String? _lastPublishedSignature;

  LeaderboardBloc({required LeaderboardRepository repository})
    : _repository = repository,
      super(const LeaderboardState()) {
    on<LoadLeaderboards>(_onLoadLeaderboards);
    on<PublishLeaderboardProgress>(_onPublishProgress);
    on<UpdateLeaderboardDisplayName>(_onUpdateDisplayName);
    on<LeaderboardEntriesUpdated>(_onLeaderboardEntriesUpdated);
    on<LeaderboardFailed>(_onLeaderboardFailed);
  }

  Future<void> _onLoadLeaderboards(
    LoadLeaderboards event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(state.copyWith(status: LeaderboardStatus.loading));

    try {
      final participant = await _repository.ensureParticipant();
      emit(
        state.copyWith(
          participantId: participant.participantId,
          displayName: participant.displayName,
        ),
      );

      await _overallSubscription?.cancel();
      await _treasureSubscription?.cancel();

      _overallSubscription = _repository
          .watchLeaderboard(LeaderboardMode.overall)
          .listen(
            (entries) => add(
              LeaderboardEntriesUpdated(
                mode: LeaderboardMode.overall,
                entries: entries,
              ),
            ),
            onError: (Object error) => add(LeaderboardFailed(error.toString())),
          );

      _treasureSubscription = _repository
          .watchLeaderboard(LeaderboardMode.treasureHunt)
          .listen(
            (entries) => add(
              LeaderboardEntriesUpdated(
                mode: LeaderboardMode.treasureHunt,
                entries: entries,
              ),
            ),
            onError: (Object error) => add(LeaderboardFailed(error.toString())),
          );
    } catch (error) {
      emit(
        state.copyWith(
          status: LeaderboardStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onPublishProgress(
    PublishLeaderboardProgress event,
    Emitter<LeaderboardState> emit,
  ) async {
    final scores = calculateLeaderboardScores(
      points: event.points,
      foundPointIds: event.foundPointIds,
      checkedInIds: event.checkedInIds,
    );
    if (scores.totalScore == 0) return;

    final signature = '${state.displayName}|${scores.signature}';
    if (_lastPublishedSignature == signature) return;

    final published = await _repository.publishProgress(
      points: event.points,
      foundPointIds: event.foundPointIds,
      checkedInIds: event.checkedInIds,
    );
    if (published) {
      _lastPublishedSignature = signature;
    }
  }

  Future<void> _onUpdateDisplayName(
    UpdateLeaderboardDisplayName event,
    Emitter<LeaderboardState> emit,
  ) async {
    final displayName = await _repository.updateDisplayName(event.displayName);
    _lastPublishedSignature = null;
    emit(state.copyWith(displayName: displayName));
  }

  void _onLeaderboardEntriesUpdated(
    LeaderboardEntriesUpdated event,
    Emitter<LeaderboardState> emit,
  ) {
    emit(
      state.copyWith(
        status: LeaderboardStatus.success,
        overallEntries: event.mode == LeaderboardMode.overall
            ? event.entries
            : state.overallEntries,
        treasureEntries: event.mode == LeaderboardMode.treasureHunt
            ? event.entries
            : state.treasureEntries,
        errorMessage: null,
      ),
    );
  }

  void _onLeaderboardFailed(
    LeaderboardFailed event,
    Emitter<LeaderboardState> emit,
  ) {
    emit(
      state.copyWith(
        status: state.overallEntries.isEmpty && state.treasureEntries.isEmpty
            ? LeaderboardStatus.error
            : LeaderboardStatus.success,
        errorMessage: event.message,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _overallSubscription?.cancel();
    await _treasureSubscription?.cancel();
    return super.close();
  }
}
