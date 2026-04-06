import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/features/admin/data/models/invalid_entry.dart';
import 'package:sggw_days/features/admin/data/repositories/admin_repository.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_event.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;

  AdminBloc({required AdminRepository adminRepository})
    : _adminRepository = adminRepository,
      super(const AdminState()) {
    on<LoadTreasurePoints>(_onLoadTreasurePoints);
    on<CreateTreasurePoint>(_onCreateTreasurePoint);
    on<UpdateTreasurePoint>(_onUpdateTreasurePoint);
    on<DeleteTreasurePoint>(_onDeleteTreasurePoint);
    on<ReorderTreasurePoints>(_onReorderTreasurePoints);

    on<LoadWikiArticles>(_onLoadWikiArticles);
    on<CreateWikiArticle>(_onCreateWikiArticle);
    on<UpdateWikiArticle>(_onUpdateWikiArticle);
    on<DeleteWikiArticle>(_onDeleteWikiArticle);

    on<LoadTimetableEvents>(_onLoadTimetableEvents);
    on<CreateTimetableEvent>(_onCreateTimetableEvent);
    on<UpdateTimetableEvent>(_onUpdateTimetableEvent);
    on<DeleteTimetableEvent>(_onDeleteTimetableEvent);

    on<FixInvalidEntry>(_onFixInvalidEntry);
    on<FixAllInvalidEntries>(_onFixAllInvalidEntries);
  }

  static const _fallbackHost = 'sggw-days.web.app';

  static String get _baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      final port = Uri.base.port;
      final scheme = Uri.base.scheme;
      if (host.isNotEmpty && host != 'localhost' && !host.startsWith('127.')) {
        return '$scheme://$host${port != 80 && port != 443 ? ':$port' : ''}';
      }
    }
    return 'https://$_fallbackHost';
  }

  // Treasure Points Handlers
  Future<void> _onLoadTreasurePoints(
    LoadTreasurePoints event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final result = await _adminRepository.fetchAndValidateTreasurePoints();
      emit(
        state.copyWith(
          status: AdminStatus.success,
          treasurePoints: result.valid,
          invalidTreasurePoints: result.invalid,
        ),
      );
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
      final created = await _adminRepository.createTreasurePoint(event.point);
      final withQr = created.copyWith(qrCode: '$_baseUrl/scan/${created.id}');
      await _adminRepository.updateTreasurePoint(withQr);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          treasurePoints: [...state.treasurePoints, withQr],
        ),
      );
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
      final updated = await _adminRepository.updateTreasurePoint(event.point);
      final updatedPoints = state.treasurePoints
          .map((p) => p.id == updated.id ? updated : p)
          .toList();
      emit(
        state.copyWith(
          status: AdminStatus.success,
          treasurePoints: updatedPoints,
        ),
      );
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
      final updatedPoints = state.treasurePoints
          .where((p) => p.id != event.id)
          .toList();
      final updatedInvalid = state.invalidTreasurePoints
          .where((e) => e.id != event.id)
          .toList();
      emit(
        state.copyWith(
          status: AdminStatus.success,
          treasurePoints: updatedPoints,
          invalidTreasurePoints: updatedInvalid,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onReorderTreasurePoints(
    ReorderTreasurePoints event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      // Update order field for each point in Firestore
      for (var i = 0; i < event.reorderedPoints.length; i++) {
        final point = event.reorderedPoints[i].copyWith(order: i);
        await _adminRepository.updateTreasurePoint(point);
      }
      // Update local state with new order
      final reordered = [
        for (var i = 0; i < event.reorderedPoints.length; i++)
          event.reorderedPoints[i].copyWith(order: i),
      ];
      // Merge with non-treasure points
      final nonTreasure = state.treasurePoints
          .where((p) => !reordered.any((r) => r.id == p.id))
          .toList();
      emit(
        state.copyWith(
          status: AdminStatus.success,
          treasurePoints: [...reordered, ...nonTreasure],
        ),
      );
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
      final result = await _adminRepository.fetchAndValidateWikiArticles();
      emit(
        state.copyWith(
          status: AdminStatus.success,
          wikiArticles: result.valid,
          invalidWikiArticles: result.invalid,
        ),
      );
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
      final created = await _adminRepository.createWikiArticle(event.article);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          wikiArticles: [...state.wikiArticles, created],
        ),
      );
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
      final updated = await _adminRepository.updateWikiArticle(event.article);
      final updatedArticles = state.wikiArticles
          .map((a) => a.id == updated.id ? updated : a)
          .toList();
      emit(
        state.copyWith(
          status: AdminStatus.success,
          wikiArticles: updatedArticles,
        ),
      );
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
      final updatedArticles = state.wikiArticles
          .where((a) => a.id != event.id)
          .toList();
      final updatedInvalid = state.invalidWikiArticles
          .where((e) => e.id != event.id)
          .toList();
      emit(
        state.copyWith(
          status: AdminStatus.success,
          wikiArticles: updatedArticles,
          invalidWikiArticles: updatedInvalid,
        ),
      );
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
      final result = await _adminRepository.fetchAndValidateTimetableEvents();
      emit(
        state.copyWith(
          status: AdminStatus.success,
          timetableEvents: result.valid,
          invalidTimetableEvents: result.invalid,
        ),
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
      final created = await _adminRepository.createTimetableEvent(event.event);
      emit(
        state.copyWith(
          status: AdminStatus.success,
          timetableEvents: [...state.timetableEvents, created],
        ),
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
      final updated = await _adminRepository.updateTimetableEvent(event.event);
      final updatedEvents = state.timetableEvents
          .map((e) => e.id == updated.id ? updated : e)
          .toList();
      emit(
        state.copyWith(
          status: AdminStatus.success,
          timetableEvents: updatedEvents,
        ),
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
      final updatedEvents = state.timetableEvents
          .where((e) => e.id != event.id)
          .toList();
      final updatedInvalid = state.invalidTimetableEvents
          .where((e) => e.id != event.id)
          .toList();
      emit(
        state.copyWith(
          status: AdminStatus.success,
          timetableEvents: updatedEvents,
          invalidTimetableEvents: updatedInvalid,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Invalid Entries Handlers
  Future<void> _onFixInvalidEntry(
    FixInvalidEntry event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      await _adminRepository.fixInvalidEntry(
        event.collection,
        event.docId,
        event.fixedData,
      );
      // Reload the affected collection
      switch (event.collection) {
        case 'treasure_points':
          final result = await _adminRepository
              .fetchAndValidateTreasurePoints();
          emit(
            state.copyWith(
              status: AdminStatus.success,
              treasurePoints: result.valid,
              invalidTreasurePoints: result.invalid,
            ),
          );
        case 'wiki_articles':
          final result = await _adminRepository.fetchAndValidateWikiArticles();
          emit(
            state.copyWith(
              status: AdminStatus.success,
              wikiArticles: result.valid,
              invalidWikiArticles: result.invalid,
            ),
          );
        case 'timetable_events':
          final result = await _adminRepository
              .fetchAndValidateTimetableEvents();
          emit(
            state.copyWith(
              status: AdminStatus.success,
              timetableEvents: result.valid,
              invalidTimetableEvents: result.invalid,
            ),
          );
      }
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onFixAllInvalidEntries(
    FixAllInvalidEntries event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final List<InvalidEntry> entries;
      switch (event.collection) {
        case 'treasure_points':
          entries = state.invalidTreasurePoints;
        case 'wiki_articles':
          entries = state.invalidWikiArticles;
        case 'timetable_events':
          entries = state.invalidTimetableEvents;
        default:
          return;
      }
      for (final entry in entries) {
        if (entry.fixedData != null) {
          await _adminRepository.fixInvalidEntry(
            event.collection,
            entry.id,
            entry.fixedData!,
          );
        }
      }
      // Reload the affected collection
      switch (event.collection) {
        case 'treasure_points':
          final result = await _adminRepository
              .fetchAndValidateTreasurePoints();
          emit(
            state.copyWith(
              status: AdminStatus.success,
              treasurePoints: result.valid,
              invalidTreasurePoints: result.invalid,
            ),
          );
        case 'wiki_articles':
          final result = await _adminRepository.fetchAndValidateWikiArticles();
          emit(
            state.copyWith(
              status: AdminStatus.success,
              wikiArticles: result.valid,
              invalidWikiArticles: result.invalid,
            ),
          );
        case 'timetable_events':
          final result = await _adminRepository
              .fetchAndValidateTimetableEvents();
          emit(
            state.copyWith(
              status: AdminStatus.success,
              timetableEvents: result.valid,
              invalidTimetableEvents: result.invalid,
            ),
          );
      }
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
