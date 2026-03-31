import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:sggw_days/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sggw_days/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(
                  state.locale == null
                      ? 'System'
                      : state.locale!.languageCode == 'pl'
                      ? 'Polski'
                      : 'English',
                ),
                onTap: () async {
                  final locale = await showDialog<Locale?>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.language),
                      content: RadioGroup<String?>(
                        groupValue: state.locale?.languageCode,
                        onChanged: (value) {
                          Navigator.of(
                            context,
                          ).pop(value == null ? null : Locale(value));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<String?>(
                              title: const Text('System'),
                              value: null,
                            ),
                            RadioListTile<String?>(
                              title: const Text('Polski'),
                              value: 'pl',
                            ),
                            RadioListTile<String?>(
                              title: const Text('English'),
                              value: 'en',
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.cancel),
                        ),
                      ],
                    ),
                  );
                  if (context.mounted) {
                    context.read<SettingsCubit>().changeLocale(locale);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: Text(l10n.theme),
                subtitle: Text(
                  state.themeMode == ThemeMode.light
                      ? 'Light'
                      : state.themeMode == ThemeMode.dark
                      ? 'Dark'
                      : 'System',
                ),
                onTap: () async {
                  final themeMode = await showDialog<ThemeMode>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.theme),
                      content: RadioGroup<ThemeMode>(
                        groupValue: state.themeMode,
                        onChanged: (value) {
                          Navigator.of(context).pop(value);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<ThemeMode>(
                              title: const Text('Light'),
                              value: ThemeMode.light,
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('Dark'),
                              value: ThemeMode.dark,
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('System'),
                              value: ThemeMode.system,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.cancel),
                        ),
                      ],
                    ),
                  );
                  if (context.mounted && themeMode != null) {
                    context.read<SettingsCubit>().changeThemeMode(themeMode);
                  }
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.palette_outlined),
                title: Text(l10n.colorScheme),
                subtitle: Text(
                  state.useDynamicColors ? l10n.dynamicColors : l10n.sggwColors,
                ),
                value: state.useDynamicColors,
                onChanged: (value) {
                  context.read<SettingsCubit>().toggleDynamicColors(value);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: Text(l10n.fontSize),
                subtitle: Slider(
                  value: state.textScaleFactor,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: '${(state.textScaleFactor * 100).round()}%',
                  onChanged: (value) {
                    context.read<SettingsCubit>().setTextScaleFactor(value);
                  },
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.format_bold),
                title: Text(l10n.boldText),
                value: state.boldText,
                onChanged: (value) {
                  context.read<SettingsCubit>().toggleBoldText(value);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.viewOnboarding),
                subtitle: Text(l10n.viewOnboardingDesc),
                onTap: () async {
                  final settingsBox = await Hive.openBox('settings');
                  if (context.mounted) {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OnboardingPage(
                          onComplete: () {
                            Navigator.of(context).pop();
                          },
                          settingsBox: settingsBox,
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(l10n.about),
                subtitle: Text(l10n.aboutDesc),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: l10n.appTitle,
                    applicationVersion: '1.0.0',
                    applicationIcon: Icon(
                      Icons.map,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    children: [
                      const SizedBox(height: 16),
                      Text(l10n.aboutContent),
                      const SizedBox(height: 16),
                      Text(
                        l10n.developedBy,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
