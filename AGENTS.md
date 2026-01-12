# SGGW Days - AI Agent Instructions

## Project Overview

Flutter web application for "Dni SGGW" (SGGW Days) university event with treasure hunt, knowledge wiki, and event timetable features.

**Stack**: Flutter 3.38.6 | Dart 3.10.7 | Material 3 | BLoC pattern | Freezed models | Hive storage

## Architecture

### Feature-Based Structure

```
lib/
├── core/               # Shared infrastructure
│   ├── theme/         # Material 3 themes with dual color schemes
│   ├── router/        # go_router with StatefulNavigationShell
│   └── connectivity/  # Network status monitoring (Cubit)
└── features/
    ├── treasure_hunt/ # QR scanning + map with proximity checks
    ├── wiki/          # Markdown articles
    ├── timetable/     # Event schedule
    ├── settings/      # User preferences (Cubit)
    └── onboarding/    # First-run with permissions
```

Each feature follows **clean architecture**:

- `data/models/` - Freezed models (abstract classes)
- `data/repositories/` - API calls with Dio
- `presentation/bloc/` - BLoC for complex state
- `presentation/cubit/` - Cubit for simple state
- `presentation/pages/` - UI widgets

### State Management

- **BLoC** for features with events: `TreasureHuntBloc`, `WikiBloc`, `TimetableBloc`
- **Cubit** for settings/utilities: `SettingsCubit`, `ConnectivityCubit`
- **MultiBlocProvider** at app root (`main.dart`) provides all blocs
- **RepositoryProvider** injects repositories to blocs

### Data Persistence

- **Hive** (not SharedPreferences) for all storage:
  - `progress` box: Treasure hunt completed QR codes
  - `settings` box: Onboarding status, locale, theme, color scheme
- Open boxes in `main()` before `runApp()`

## Critical Patterns

### Freezed Models

ALL data models use **abstract classes** (not regular classes):

```dart
@freezed
abstract class TreasurePoint with _$TreasurePoint {
  const factory TreasurePoint({...}) = _TreasurePoint;
  factory TreasurePoint.fromJson(Map<String, dynamic> json) => ...;
}
```

Run `dart run build_runner build --delete-conflicting-outputs` after model changes.

### Material 3 Compliance

- Use `withValues(alpha: 0.5)` NOT `withOpacity(0.5)` (deprecated)
- Use `RadioGroup` wrapper for radio buttons, NOT individual `Radio` with `groupValue`/`onChanged`
- Always check `context.mounted` before using BuildContext after `await`

### Localization

- Keys use **descriptive names**: `onboardingTreasureHuntDesc` NOT `onboardingDesc1`
- Files: `lib/l10n/app_en.arb`, `app_pl.arb`
- Regenerate: `flutter gen-l10n` (auto-runs via `l10n.yaml`)
- Default locale: `null` (inherits system language)

### Error Handling in Repositories

Return **empty lists** on 404, don't throw:

```dart
try {
  final response = await _dio.get('$_baseUrl/data.json');
  return parseData(response.data);
} on DioException catch (e) {
  if (e.response?.statusCode == 404) return [];
  throw Exception('Failed to load: $e');
}
```

### Theme System

Two color schemes toggle via `SettingsCubit.useDynamicColors`:

- **SGGW branded**: `AppColors.sggwLightScheme` / `sggwDarkScheme` (manual ColorScheme)
- **Dynamic Material 3**: `ColorScheme.fromSeed(seedColor: primaryGreen)`

Theme methods: `AppTheme.light({bool useDynamicColors})` / `AppTheme.dark({bool useDynamicColors})`

## Developer Workflows

### Code Generation

```powershell
# After changing Freezed models, JSON serialization, or Hive adapters
dart run build_runner build --delete-conflicting-outputs

# After changing localization .arb files (or let l10n.yaml auto-generate)
flutter gen-l10n
```

### Quality Assurance

```powershell
dart analyze              # Must be clean before commits
dart fix --apply          # Auto-fix deprecations
dart format lib/ test/    # Format code
```

### Running the App

```powershell
flutter run -d chrome                    # Web development
flutter build web --release              # Production build
```

### Permissions

- **Camera**: QR code scanning
- **Location**: Proximity checks (50m radius for treasure hunt)
- Request in onboarding; check with `Permission.camera.status`

## Common Tasks

### Adding a New Feature

1. Create `features/feature_name/` with `data/`, `presentation/` subdirs
2. Define Freezed model in `data/models/`
3. Create repository in `data/repositories/` (handle 404s)
4. Add BLoC/Cubit in `presentation/bloc/` or `presentation/cubit/`
5. Build UI in `presentation/pages/`
6. Register in `main.dart` providers and `app_router.dart`
7. Run code generation: `dart run build_runner build --delete-conflicting-outputs`

### Adding Localization Strings

1. Add keys to `lib/l10n/app_en.arb` and `app_pl.arb`
2. Use descriptive names: `featureName[Title|Desc|Button]`
3. Run `flutter gen-l10n` (or save file, auto-generates)
4. Access via `AppLocalizations.of(context)!.keyName`

### Updating Settings

Settings are in `SettingsCubit` (NOT Hive directly):

- `changeLocale(Locale?)` - null for system default
- `changeThemeMode(ThemeMode)` - light/dark/system
- `toggleDynamicColors(bool)` - SGGW vs Material 3 colors

### Proximity-Based Features

Use `geolocator` package:

```dart
Position position = await Geolocator.getCurrentPosition();
double distance = Geolocator.distanceBetween(
  position.latitude, position.longitude,
  targetLat, targetLon,
);
if (distance <= 50) { /* allow action */ }
```

## Project-Specific Rules

1. **Never use SharedPreferences** - all persistence uses Hive
2. **All Freezed classes must be abstract** - required for mixin pattern
3. **404 responses return empty lists** - don't crash the app
4. **Onboarding completion triggers from "Done" button** - permissions button only requests permissions
5. **Use descriptive localization keys** - avoid numbered suffixes like `title1`, `desc2`
6. **Material 3 APIs only** - avoid deprecated Material 2 widgets
7. **Nullable locale** - `null` means system default, not English
8. **StatefulNavigationShell** - maintains bottom nav state across tab switches

## Key Files

- `lib/main.dart` - App entry, Hive init, onboarding check, provider tree
- `lib/core/theme/app_theme.dart` - Dual color scheme system
- `lib/core/router/app_router.dart` - Navigation with StatefulShellRoute
- `lib/l10n/app_*.arb` - Localization strings (Polish & English)
- `pubspec.yaml` - Dependencies (check before adding duplicates)

## Testing & Debugging

- Check `dart analyze` output before committing (must be clean)
- Use Flutter DevTools for BLoC inspector
- Test onboarding flow: delete Hive `settings` box to re-trigger
- Web debugging: `flutter run -d chrome --web-renderer html` for better compatibility
