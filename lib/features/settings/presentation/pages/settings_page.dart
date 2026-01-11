import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('System'),
                            leading: Radio<String?>(
                              value: null,
                              groupValue: state.locale?.languageCode,
                              onChanged: (_) {
                                Navigator.of(context).pop(null);
                              },
                            ),
                            onTap: () {
                              Navigator.of(context).pop(null);
                            },
                          ),
                          ListTile(
                            title: const Text('Polski'),
                            leading: Radio<String?>(
                              value: 'pl',
                              groupValue: state.locale?.languageCode,
                              onChanged: (_) {
                                Navigator.of(context).pop(const Locale('pl'));
                              },
                            ),
                            onTap: () {
                              Navigator.of(context).pop(const Locale('pl'));
                            },
                          ),
                          ListTile(
                            title: const Text('English'),
                            leading: Radio<String?>(
                              value: 'en',
                              groupValue: state.locale?.languageCode,
                              onChanged: (_) {
                                Navigator.of(context).pop(const Locale('en'));
                              },
                            ),
                            onTap: () {
                              Navigator.of(context).pop(const Locale('en'));
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.cancel),
                        ),
                      ],
                    ),
                  );
                  context.read<SettingsCubit>().changeLocale(locale);
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
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Light'),
                            leading: Radio<ThemeMode>(
                              value: ThemeMode.light,
                              groupValue: state.themeMode,
                              onChanged: (_) {
                                Navigator.of(context).pop(ThemeMode.light);
                              },
                            ),
                            onTap: () {
                              Navigator.of(context).pop(ThemeMode.light);
                            },
                          ),
                          ListTile(
                            title: const Text('Dark'),
                            leading: Radio<ThemeMode>(
                              value: ThemeMode.dark,
                              groupValue: state.themeMode,
                              onChanged: (_) {
                                Navigator.of(context).pop(ThemeMode.dark);
                              },
                            ),
                            onTap: () {
                              Navigator.of(context).pop(ThemeMode.dark);
                            },
                          ),
                          ListTile(
                            title: const Text('System'),
                            leading: Radio<ThemeMode>(
                              value: ThemeMode.system,
                              groupValue: state.themeMode,
                              onChanged: (_) {
                                Navigator.of(context).pop(ThemeMode.system);
                              },
                            ),
                            onTap: () {
                              Navigator.of(context).pop(ThemeMode.system);
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.cancel),
                        ),
                      ],
                    ),
                  );
                  if (themeMode != null) {
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
            ],
          );
        },
      ),
    );
  }
}
