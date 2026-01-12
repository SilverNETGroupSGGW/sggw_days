import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/features/admin/data/repositories/admin_repository.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_event.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_state.dart';
import 'package:sggw_days/features/timetable/data/repositories/timetable_repository.dart';
import 'package:sggw_days/features/treasure_hunt/data/repositories/treasure_hunt_repository.dart';
import 'package:sggw_days/features/wiki/data/repositories/wiki_repository.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;
  final TreasureHuntRepository _treasureHuntRepository;
  final WikiRepository _wikiRepository;
  final TimetableRepository _timetableRepository;

  AdminBloc({
    required AdminRepository adminRepository,
    required TreasureHuntRepository treasureHuntRepository,
    required WikiRepository wikiRepository,
    required TimetableRepository timetableRepository,
  }) : _adminRepository = adminRepository,
       _treasureHuntRepository = treasureHuntRepository,
       _wikiRepository = wikiRepository,
       _timetableRepository = timetableRepository,
       super(const AdminState()) {
    on<LoadTreasurePoints>(_onLoadTreasurePoints);
    on<CreateTreasurePoint>(_onCreateTreasurePoint);
    on<UpdateTreasurePoint>(_onUpdateTreasurePoint);
    on<DeleteTreasurePoint>(_onDeleteTreasurePoint);

    on<LoadWikiArticles>(_onLoadWikiArticles);
    on<CreateWikiArticle>(_onCreateWikiArticle);
    on<UpdateWikiArticle>(_onUpdateWikiArticle);
    on<DeleteWikiArticle>(_onDeleteWikiArticle);

    on<LoadTimetableEvents>(_onLoadTimetableEvents);
    on<CreateTimetableEvent>(_onCreateTimetableEvent);
    on<UpdateTimetableEvent>(_onUpdateTimetableEvent);
    on<DeleteTimetableEvent>(_onDeleteTimetableEvent);
  }

  // Treasure Points Handlers
  Future<void> _onLoadTreasurePoints(
    LoadTreasurePoints event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final points = await _treasureHuntRepository.getTreasurePoints();
      emit(state.copyWith(status: AdminStatus.success, treasurePoints: points));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCreateTreasurePoint(
    CreateTreasurePoint event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminRepository.createTreasurePoint(event.point);
      final points = await _treasureHuntRepository.getTreasurePoints();
      emit(state.copyWith(status: AdminStatus.success, treasurePoints: points));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateTreasurePoint(
    UpdateTreasurePoint event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminRepository.updateTreasurePoint(event.point);
      final points = await _treasureHuntRepository.getTreasurePoints();
      emit(state.copyWith(status: AdminStatus.success, treasurePoints: points));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeleteTreasurePoint(
    DeleteTreasurePoint event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminRepository.deleteTreasurePoint(event.id);
      final points = await _treasureHuntRepository.getTreasurePoints();
      emit(state.copyWith(status: AdminStatus.success, treasurePoints: points));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Wiki Articles Handlers
  Future<void> _onLoadWikiArticles(
    LoadWikiArticles event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final articles = await _wikiRepository.getArticles();
      emit(state.copyWith(status: AdminStatus.success, wikiArticles: articles));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCreateWikiArticle(
    CreateWikiArticle event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminRepository.createWikiArticle(event.article);
      final articles = await _wikiRepository.getArticles();
      emit(state.copyWith(status: AdminStatus.success, wikiArticles: articles));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateWikiArticle(
    UpdateWikiArticle event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminRepository.updateWikiArticle(event.article);
      final articles = await _wikiRepository.getArticles();
      emit(state.copyWith(status: AdminStatus.success, wikiArticles: articles));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeleteWikiArticle(
    DeleteWikiArticle event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminRepository.deleteWikiArticle(event.id);
      final articles = await _wikiRepository.getArticles();
      emit(state.copyWith(status: AdminStatus.success, wikiArticles: articles));
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Timetable Events Handlers
  Future<void> _onLoadTimetableEvents(
    LoadTimetableEvents event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final events = await _timetableRepository.getEvents();
      emit(
        state.copyWith(status: AdminStatus.success, timetableEvents: events),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCreateTimetableEvent(
    CreateTimetableEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminRepository.createTimetableEvent(event.event);
      final events = await _timetableRepository.getEvents();
      emit(
        state.copyWith(status: AdminStatus.success, timetableEvents: events),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateTimetableEvent(
    UpdateTimetableEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminRepository.updateTimetableEvent(event.event);
      final events = await _timetableRepository.getEvents();
      emit(
        state.copyWith(status: AdminStatus.success, timetableEvents: events),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeleteTimetableEvent(
    DeleteTimetableEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminRepository.deleteTimetableEvent(event.id);
      final events = await _timetableRepository.getEvents();
      emit(
        state.copyWith(status: AdminStatus.success, timetableEvents: events),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
