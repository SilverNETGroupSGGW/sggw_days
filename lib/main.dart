import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sggw_days/core/connectivity/connectivity_cubit.dart';
import 'package:sggw_days/core/router/app_router.dart';
import 'package:sggw_days/core/theme/app_theme.dart';
import 'package:sggw_days/features/admin/data/repositories/admin_repository.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sggw_days/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sggw_days/features/timetable/data/repositories/timetable_repository.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/data/repositories/treasure_hunt_repository.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/wiki/data/repositories/wiki_repository.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_bloc.dart';
import 'package:sggw_days/firebase_options.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {}

  await Hive.initFlutter();
  final progressBox = await Hive.openBox<List<String>>('progress');
  final settingsBox = await Hive.openBox('settings');

  runApp(MyApp(progressBox: progressBox, settingsBox: settingsBox));
}

class MyApp extends StatefulWidget {
  final Box<List<String>> progressBox;
  final Box<dynamic> settingsBox;

  const MyApp({
    super.key,
    required this.progressBox,
    required this.settingsBox,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _onboardingCompleted = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    setState(() {
      _onboardingCompleted =
          widget.settingsBox.get('onboarding_completed', defaultValue: false)
              as bool;
      _loading = false;
    });
  }

  void _completeOnboarding() {
    setState(() {
      _onboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (!_onboardingCompleted) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('pl')],
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: OnboardingPage(
          onComplete: _completeOnboarding,
          settingsBox: widget.settingsBox,
        ),
      );
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => TreasureHuntRepository()),
        RepositoryProvider(create: (context) => WikiRepository()),
        RepositoryProvider(create: (context) => TimetableRepository()),
        RepositoryProvider(create: (context) => AdminRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SettingsCubit(settingsBox: widget.settingsBox),
          ),
          BlocProvider(create: (context) => ConnectivityCubit()),
          BlocProvider(
            create: (context) => TreasureHuntBloc(
              repository: context.read<TreasureHuntRepository>(),
              progressBox: widget.progressBox,
            ),
          ),
          BlocProvider(
            create: (context) =>
                WikiBloc(repository: context.read<WikiRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                TimetableBloc(repository: context.read<TimetableRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                AdminBloc(adminRepository: context.read<AdminRepository>()),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return MaterialApp.router(
              title: 'Dni SGGW',
              theme: AppTheme.light(
                useDynamicColors: settings.useDynamicColors,
                boldText: settings.boldText,
              ),
              darkTheme: AppTheme.dark(
                useDynamicColors: settings.useDynamicColors,
                boldText: settings.boldText,
              ),
              themeMode: settings.themeMode,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('pl'), Locale('en')],
              locale: settings.locale,
              routerConfig: appRouter,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(settings.textScaleFactor),
                  ),
                  child: child!,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
