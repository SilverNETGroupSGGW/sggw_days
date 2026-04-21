import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/data/repositories/treasure_hunt_repository.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/pages/scan_page.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class _FakeTreasureHuntRepository extends TreasureHuntRepository {
  _FakeTreasureHuntRepository(this.points);

  final List<TreasurePoint> points;

  @override
  Future<List<TreasurePoint>> getTreasurePoints() async => points;
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

class _InMemoryProgressBox extends Fake implements Box<List<String>> {
  final Map<dynamic, List<String>> _storage = {};

  @override
  List<String>? get(dynamic key, {List<String>? defaultValue}) {
    return _storage[key] ?? defaultValue;
  }

  @override
  Future<void> put(dynamic key, List<String> value) async {
    _storage[key] = List<String>.from(value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opening ScanPage does not mark the point as found', (
    tester,
  ) async {
    const point = TreasurePoint(
      id: 'point-1',
      name: 'Test Point',
      description: 'Point description',
      latitude: 52.1598,
      longitude: 21.0463,
      qrCode: 'https://sggw-days.web.app/scan/point-1',
    );
    final progressBox = _InMemoryProgressBox();
    late _SeededTreasureHuntBloc bloc;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('pl')],
        home: BlocProvider<TreasureHuntBloc>(
          create: (_) {
            bloc = _SeededTreasureHuntBloc(
              repository: _FakeTreasureHuntRepository(const [point]),
              progressBox: progressBox,
              points: const [point],
            );
            return bloc;
          },
          child: const ScanPage(pointId: 'point-1'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Test Point'), findsOneWidget);
    expect(bloc.state.foundPointIds, isEmpty);
    expect(progressBox.get('found_points'), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
