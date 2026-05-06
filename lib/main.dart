import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sggw_days/core/connectivity/connectivity_cubit.dart';
import 'package:sggw_days/core/router/app_router.dart';
import 'package:sggw_days/core/theme/dynamic_color_availability.dart';
import 'package:sggw_days/core/theme/app_theme.dart';
import 'package:sggw_days/features/admin/data/repositories/admin_repository.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/notifications/data/event_reminder_service.dart';
import 'package:sggw_days/features/notifications/data/notification_repository.dart';
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
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
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
  final onboardingCompleted =
      settingsBox.get('onboarding_completed', defaultValue: false) as bool;

  runApp(
    MyApp(
      progressBox: progressBox,
      settingsBox: settingsBox,
      initialOnboardingCompleted: onboardingCompleted,
    ),
  );
}

class MyApp extends StatefulWidget {
  final Box<List<String>> progressBox;
  final Box<dynamic> settingsBox;
  final bool initialOnboardingCompleted;

  const MyApp({
    super.key,
    required this.progressBox,
    required this.settingsBox,
    required this.initialOnboardingCompleted,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _onboardingCompleted = widget.initialOnboardingCompleted;
  }

  void _completeOnboarding() {
    setState(() {
      _onboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        RepositoryProvider(
          create: (context) {
            final service = EventReminderService(
              settingsBox: widget.settingsBox,
            );
            unawaited(service.initialize());
            return service;
          },
        ),
        RepositoryProvider(
          create: (context) {
            final repository = NotificationRepository(
              settingsBox: widget.settingsBox,
            );
            repository.startTokenRefreshListener();
            unawaited(repository.refreshRegistrationIfEnabled());
            return repository;
          },
          dispose: (repository) => unawaited(repository.dispose()),
        ),
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
            create: (context) => TimetableBloc(
              repository: context.read<TimetableRepository>(),
              eventReminderService: context.read<EventReminderService>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                AdminBloc(adminRepository: context.read<AdminRepository>()),
          ),
        ],
        child: DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            final supportsDynamicColors =
                lightDynamic != null && darkDynamic != null;
            return BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settings) {
                final useDynamicColors =
                    settings.useDynamicColors && supportsDynamicColors;
                return DynamicColorAvailability(
                  isSupported: supportsDynamicColors,
                  child: MaterialApp.router(
                    title: 'Dni SGGW',
                    theme: AppTheme.light(
                      useDynamicColors: useDynamicColors,
                      dynamicColorScheme: lightDynamic,
                      boldText: settings.boldText,
                    ),
                    darkTheme: AppTheme.dark(
                      useDynamicColors: useDynamicColors,
                      dynamicColorScheme: darkDynamic,
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
                          textScaler: TextScaler.linear(
                            settings.textScaleFactor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
