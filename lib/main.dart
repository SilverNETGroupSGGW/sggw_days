import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sggw_days/core/router/app_router.dart';
import 'package:sggw_days/core/theme/app_theme.dart';
import 'package:sggw_days/features/timetable/data/repositories/timetable_repository.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/data/repositories/treasure_hunt_repository.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/wiki/data/repositories/wiki_repository.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_bloc.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final progressBox = await Hive.openBox<List<String>>('progress');

  runApp(MyApp(progressBox: progressBox));
}

class MyApp extends StatelessWidget {
  final Box<List<String>> progressBox;

  const MyApp({super.key, required this.progressBox});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => TreasureHuntRepository()),
        RepositoryProvider(create: (context) => WikiRepository()),
        RepositoryProvider(create: (context) => TimetableRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TreasureHuntBloc(
              repository: context.read<TreasureHuntRepository>(),
              progressBox: progressBox,
            ),
          ),
          BlocProvider(
            create: (context) => WikiBloc(
              repository: context.read<WikiRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => TimetableBloc(
              repository: context.read<TimetableRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'Dni SGGW',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pl'),
            Locale('en'),
          ],
          locale: const Locale('pl'),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
