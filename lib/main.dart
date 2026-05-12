import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sggw_days/core/config/scan_distance_config.dart';
import 'package:sggw_days/core/connectivity/connectivity_cubit.dart';
import 'package:sggw_days/core/device/device_identity_service.dart';
import 'package:sggw_days/core/router/app_router.dart';
import 'package:sggw_days/core/theme/app_theme.dart';
import 'package:sggw_days/core/theme/dynamic_color_availability.dart';
import 'package:sggw_days/features/admin/data/repositories/admin_repository.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/notifications/data/event_reminder_service.dart';
import 'package:sggw_days/features/notifications/data/notification_repository.dart';
import 'package:sggw_days/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sggw_days/features/rewards/data/repositories/reward_repository.dart';
import 'package:sggw_days/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sggw_days/features/timetable/data/repositories/timetable_repository.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:sggw_days/features/treasure_hunt/data/repositories/treasure_hunt_repository.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_event.dart';
import 'package:sggw_days/features/wiki/data/repositories/wiki_repository.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_bloc.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_event.dart';
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
  final scanDistanceConfig = await _createScanDistanceConfig();
  final onboardingCompleted =
      settingsBox.get('onboarding_completed', defaultValue: false) as bool;

  runApp(
    MyApp(
      progressBox: progressBox,
      settingsBox: settingsBox,
      scanDistanceConfig: scanDistanceConfig,
      initialOnboardingCompleted: onboardingCompleted,
    ),
  );
}

Future<ScanDistanceConfig> _createScanDistanceConfig() async {
  try {
    final config = ScanDistanceConfig();
    await config.initialize();
    return config;
  } catch (_) {
    return ScanDistanceConfig.fallback();
  }
}

class MyApp extends StatefulWidget {
  final Box<List<String>> progressBox;
  final Box<dynamic> settingsBox;
  final ScanDistanceConfig scanDistanceConfig;
  final bool initialOnboardingCompleted;

  const MyApp({
    super.key,
    required this.progressBox,
    required this.settingsBox,
    required this.scanDistanceConfig,
    required this.initialOnboardingCompleted,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _onboardingCompleted;
  late final EventReminderService _eventReminderService;
  late final NotificationRepository _notificationRepository;

  @override
  void initState() {
    super.initState();
    _onboardingCompleted = widget.initialOnboardingCompleted;
    _eventReminderService = EventReminderService(
      settingsBox: widget.settingsBox,
    );
    unawaited(_eventReminderService.initialize());
    _notificationRepository = NotificationRepository(
      settingsBox: widget.settingsBox,
    );
    _notificationRepository.startTokenRefreshListener();
    unawaited(_notificationRepository.refreshRegistrationIfEnabled());
  }

  @override
  void dispose() {
    unawaited(_eventReminderService.dispose());
    unawaited(_notificationRepository.dispose());
    super.dispose();
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
          eventReminderService: _eventReminderService,
          notificationRepository: _notificationRepository,
        ),
      );
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => TreasureHuntRepository()),
        RepositoryProvider(create: (context) => WikiRepository()),
        RepositoryProvider(create: (context) => TimetableRepository()),
        RepositoryProvider(create: (context) => AdminRepository()),
        RepositoryProvider.value(value: widget.scanDistanceConfig),
        RepositoryProvider(
          create: (context) =>
              DeviceIdentityService(settingsBox: widget.settingsBox),
        ),
        RepositoryProvider(
          create: (context) => RewardRepository(
            deviceIdentityService: context.read<DeviceIdentityService>(),
            scanDistanceConfig: context.read<ScanDistanceConfig>(),
          ),
        ),
        RepositoryProvider.value(value: _eventReminderService),
        RepositoryProvider.value(value: _notificationRepository),
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
            )..add(const LoadTreasurePoints()),
          ),
          BlocProvider(
            create: (context) =>
                WikiBloc(repository: context.read<WikiRepository>())
                  ..add(const LoadWikiArticles()),
          ),
          BlocProvider(
            create: (context) => TimetableBloc(
              repository: context.read<TimetableRepository>(),
              eventReminderService: context.read<EventReminderService>(),
            )..add(const LoadTimetableEvents()),
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
