import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart'
    as model;
import 'package:sggw_days/features/timetable/data/repositories/timetable_repository.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_state.dart';

class _StreamingTimetableRepository extends TimetableRepository {
  final StreamController<List<model.TimetableEvent>> controller =
      StreamController<List<model.TimetableEvent>>();

  @override
  Future<List<model.TimetableEvent>> getEvents() async => const [];

  @override
  Stream<List<model.TimetableEvent>> watchEvents() => controller.stream;
}

void main() {
  late Directory tempDirectory;

  setUpAll(() {
    tempDirectory = Directory.systemTemp.createTempSync(
      'sggw_days_timetable_bloc_test_',
    );
    Hive.init(tempDirectory.path);
  });

  tearDown(() async {
    if (Hive.isBoxOpen('favorites')) {
      await Hive.box<List<String>>('favorites').close();
    }
    if (Hive.isBoxOpen('check_ins')) {
      await Hive.box<List<String>>('check_ins').close();
    }
    await Hive.deleteBoxFromDisk('favorites');
    await Hive.deleteBoxFromDisk('check_ins');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test('keeps selected date and favorites when events change', () async {
    final selectedDay = DateTime(2026, 5, 20);
    final favorite = _event(
      id: 'favorite',
      title: 'Favorite Event',
      startTime: selectedDay,
      tags: const ['science'],
    );
    final otherDay = _event(
      id: 'other-day',
      title: 'Other Day',
      startTime: DateTime(2026, 5, 21),
      tags: const ['science'],
    );
    final updatedFavorite = _event(
      id: 'favorite',
      title: 'Updated Favorite Event',
      startTime: selectedDay,
      tags: const ['science'],
    );

    final favoritesBox = await Hive.openBox<List<String>>('favorites');
    await favoritesBox.put('timetable_favorites', const ['favorite']);
    final repository = _StreamingTimetableRepository();
    final bloc = TimetableBloc(repository: repository);

    final firstSnapshot = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TimetableState>().having(
          (state) => state.events.length,
          'event count',
          2,
        ),
      ),
    );
    bloc.add(const LoadTimetableEvents());
    bloc.add(FilterEventsByDate(selectedDay));
    bloc.add(const ToggleShowFavorites());
    repository.controller.add([favorite, otherDay]);
    await firstSnapshot;

    final updatedSnapshot = expectLater(
      bloc.stream,
      emitsThrough(
        isA<TimetableState>()
            .having(
              (state) => state.filteredEvents.map((event) => event.title),
              'filtered titles',
              ['Updated Favorite Event'],
            )
            .having((state) => state.favoriteIds, 'favorites', const [
              'favorite',
            ])
            .having(
              (state) => state.showFavoritesOnly,
              'show favorites only',
              isTrue,
            ),
      ),
    );
    repository.controller.add([updatedFavorite, otherDay]);
    await updatedSnapshot;

    await bloc.close();
    await repository.controller.close();
  });
}

model.TimetableEvent _event({
  required String id,
  required String title,
  required DateTime startTime,
  required List<String> tags,
}) {
  return model.TimetableEvent(
    id: id,
    title: title,
    description: 'Description',
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 1)),
    location: 'Campus',
    tags: tags,
  );
}
