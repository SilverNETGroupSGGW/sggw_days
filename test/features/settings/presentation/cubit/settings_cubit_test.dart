import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/settings/presentation/cubit/settings_cubit.dart';

void main() {
  late Directory tempDirectory;

  setUpAll(() {
    tempDirectory = Directory.systemTemp.createTempSync(
      'sggw_days_settings_cubit_test_',
    );
    Hive.init(tempDirectory.path);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('settings_cubit_test');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test('hydrates settings state from Hive', () async {
    final settingsBox = await Hive.openBox<dynamic>('settings_cubit_test');
    await settingsBox.put('locale', 'en');
    await settingsBox.put('theme_mode', 'dark');
    await settingsBox.put('use_dynamic_colors', true);
    await settingsBox.put('text_scale_factor', 1.2);
    await settingsBox.put('bold_text', true);
    await settingsBox.put('non_game_mode', true);

    final cubit = SettingsCubit(settingsBox: settingsBox);

    expect(cubit.state.locale, const Locale('en'));
    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(cubit.state.useDynamicColors, isTrue);
    expect(cubit.state.textScaleFactor, 1.2);
    expect(cubit.state.boldText, isTrue);
    expect(cubit.state.skipTreasureHunt, isTrue);

    await cubit.close();
    await settingsBox.close();
  });

  test('persists updated settings back to Hive', () async {
    final settingsBox = await Hive.openBox<dynamic>('settings_cubit_test');
    final cubit = SettingsCubit(settingsBox: settingsBox);

    cubit.changeLocale(const Locale('pl'));
    cubit.changeThemeMode(ThemeMode.light);
    cubit.toggleDynamicColors(true);
    cubit.setTextScaleFactor(1.1);
    cubit.toggleBoldText(true);
    cubit.setSkipTreasureHunt(true);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    await settingsBox.flush();

    expect(settingsBox.get('locale'), 'pl');
    expect(settingsBox.get('theme_mode'), 'light');
    expect(settingsBox.get('use_dynamic_colors'), isTrue);
    expect(settingsBox.get('text_scale_factor'), 1.1);
    expect(settingsBox.get('bold_text'), isTrue);
    expect(settingsBox.get('non_game_mode'), isTrue);

    await cubit.close();
    await settingsBox.close();
  });

  test('reloads settings after external Hive writes', () async {
    final settingsBox = await Hive.openBox<dynamic>('settings_cubit_test');
    final cubit = SettingsCubit(settingsBox: settingsBox);

    await settingsBox.put('locale', 'en');
    await settingsBox.put('theme_mode', 'dark');
    await settingsBox.put('non_game_mode', true);

    expect(cubit.state.locale, isNull);
    expect(cubit.state.themeMode, ThemeMode.system);
    expect(cubit.state.skipTreasureHunt, isFalse);

    cubit.reloadFromStorage();

    expect(cubit.state.locale, const Locale('en'));
    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(cubit.state.skipTreasureHunt, isTrue);

    await cubit.close();
    await settingsBox.close();
  });
}
