import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
    : super(
        const SettingsState(
          locale: null,
          themeMode: ThemeMode.system,
          useDynamicColors: false,
        ),
      );

  void changeLocale(Locale? locale) {
    if (locale == null) {
      emit(state.copyWith(clearLocale: true));
    } else {
      emit(state.copyWith(locale: locale));
    }
  }

  void changeThemeMode(ThemeMode themeMode) {
    emit(state.copyWith(themeMode: themeMode));
  }

  void toggleDynamicColors(bool value) {
    emit(state.copyWith(useDynamicColors: value));
  }
}
