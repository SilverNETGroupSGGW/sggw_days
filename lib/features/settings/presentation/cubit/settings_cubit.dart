import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const _localeKey = 'locale';
  static const _themeModeKey = 'theme_mode';
  static const _dynamicColorsKey = 'use_dynamic_colors';
  static const _textScaleFactorKey = 'text_scale_factor';
  static const _boldTextKey = 'bold_text';
  static const _skipTreasureHuntKey = 'non_game_mode';

  final Box<dynamic> _settingsBox;
    Box<dynamic> get settingsBox => _settingsBox;

  SettingsCubit({required Box<dynamic> settingsBox})
    : _settingsBox = settingsBox,
      super(_restoreState(settingsBox));

    static SettingsState _restoreState(Box<dynamic> settingsBox) {
    return SettingsState(
      locale: _readLocale(settingsBox),
      themeMode: _readThemeMode(settingsBox),
      useDynamicColors:
        settingsBox.get(_dynamicColorsKey, defaultValue: false) as bool? ??
        false,
      textScaleFactor:
        (settingsBox.get(_textScaleFactorKey, defaultValue: 1.0) as num?)
          ?.toDouble() ??
        1.0,
      boldText:
        settingsBox.get(_boldTextKey, defaultValue: false) as bool? ??
        false,
      skipTreasureHunt:
        settingsBox.get(_skipTreasureHuntKey, defaultValue: false)
          as bool? ??
        false,
    );
    }

  static Locale? _readLocale(Box<dynamic> settingsBox) {
    final languageCode = settingsBox.get(_localeKey) as String?;
    if (languageCode == null || languageCode.isEmpty) {
      return null;
    }
    return Locale(languageCode);
  }

  static ThemeMode _readThemeMode(Box<dynamic> settingsBox) {
    final value = settingsBox.get(_themeModeKey) as String?;
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void _saveSetting(String key, Object? value) {
    unawaited(_settingsBox.put(key, value));
  }

  void _deleteSetting(String key) {
    unawaited(_settingsBox.delete(key));
  }

  void changeLocale(Locale? locale) {
    if (locale == null) {
      _deleteSetting(_localeKey);
      emit(state.copyWith(clearLocale: true));
      return;
    }

    _saveSetting(_localeKey, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  void changeThemeMode(ThemeMode themeMode) {
    _saveSetting(_themeModeKey, themeMode.name);
    emit(state.copyWith(themeMode: themeMode));
  }

  void toggleDynamicColors(bool value) {
    _saveSetting(_dynamicColorsKey, value);
    emit(state.copyWith(useDynamicColors: value));
  }

  void setTextScaleFactor(double value) {
    _saveSetting(_textScaleFactorKey, value);
    emit(state.copyWith(textScaleFactor: value));
  }

  void toggleBoldText(bool value) {
    _saveSetting(_boldTextKey, value);
    emit(state.copyWith(boldText: value));
  }

  void reloadFromStorage() {
    emit(_restoreState(_settingsBox));
  }

  void setSkipTreasureHunt(bool value) {
    _saveSetting(_skipTreasureHuntKey, value);
    emit(state.copyWith(skipTreasureHunt: value));
  }
}
