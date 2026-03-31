part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final Locale? locale;
  final ThemeMode themeMode;
  final bool useDynamicColors;
  final double textScaleFactor;
  final bool boldText;

  const SettingsState({
    required this.locale,
    required this.themeMode,
    required this.useDynamicColors,
    this.textScaleFactor = 1.0,
    this.boldText = false,
  });

  SettingsState copyWith({
    Locale? locale,
    bool clearLocale = false,
    ThemeMode? themeMode,
    bool? useDynamicColors,
    double? textScaleFactor,
    bool? boldText,
  }) {
    return SettingsState(
      locale: clearLocale ? null : (locale ?? this.locale),
      themeMode: themeMode ?? this.themeMode,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      boldText: boldText ?? this.boldText,
    );
  }

  @override
  List<Object?> get props => [locale, themeMode, useDynamicColors, textScaleFactor, boldText];
}
