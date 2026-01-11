part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final Locale? locale;
  final ThemeMode themeMode;
  final bool useDynamicColors;

  const SettingsState({
    required this.locale,
    required this.themeMode,
    required this.useDynamicColors,
  });

  SettingsState copyWith({
    Locale? locale,
    bool clearLocale = false,
    ThemeMode? themeMode,
    bool? useDynamicColors,
  }) {
    return SettingsState(
      locale: clearLocale ? null : (locale ?? this.locale),
      themeMode: themeMode ?? this.themeMode,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
    );
  }

  @override
  List<Object?> get props => [locale, themeMode, useDynamicColors];
}
