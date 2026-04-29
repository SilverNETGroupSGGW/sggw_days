import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sggw_days/core/theme/dynamic_color_availability.dart';
import 'package:sggw_days/features/notifications/data/event_reminder_service.dart';
import 'package:sggw_days/features/notifications/data/notification_repository.dart';
import 'package:sggw_days/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sggw_days/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationBusy = false;
  bool _eventRemindersEnabled = false;
  bool _pushNotificationsEnabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _eventRemindersEnabled = context
        .read<EventReminderService>()
        .remindersEnabled;
    _pushNotificationsEnabled = context
        .read<NotificationRepository>()
        .pushNotificationsEnabled;
  }

  Future<void> _toggleEventReminders(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    final reminderService = context.read<EventReminderService>();
    setState(() => _notificationBusy = true);
    try {
      if (value) {
        final granted = await reminderService.enableReminders();
        if (granted) {
          if (!mounted) return;
          final timetableState = context.read<TimetableBloc>().state;
          await reminderService.scheduleFavoriteEventReminders(
            timetableState.events,
            timetableState.favoriteIds,
          );
        }
        if (!mounted) return;
        setState(() => _eventRemindersEnabled = granted);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              granted
                  ? l10n.eventRemindersEnabledSnack
                  : l10n.notificationPermissionDenied,
            ),
          ),
        );
      } else {
        await reminderService.disableReminders();
        if (!mounted) return;
        setState(() => _eventRemindersEnabled = false);
      }
    } finally {
      if (mounted) setState(() => _notificationBusy = false);
    }
  }

  Future<void> _togglePushNotifications(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    final notificationRepository = context.read<NotificationRepository>();
    setState(() => _notificationBusy = true);
    try {
      if (value) {
        final result = await notificationRepository.enablePushNotifications();
        if (!mounted) return;
        setState(() => _pushNotificationsEnabled = result.enabled);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.enabled
                  ? l10n.pushNotificationsEnabledSnack
                  : result.message ?? l10n.notificationPermissionDenied,
            ),
          ),
        );
      } else {
        await notificationRepository.disablePushNotifications();
        if (!mounted) return;
        setState(() => _pushNotificationsEnabled = false);
      }
    } finally {
      if (mounted) setState(() => _notificationBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reminderService = context.read<EventReminderService>();
    final supportsDynamicColors = DynamicColorAvailability.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.campaign_outlined),
                title: Text(l10n.pushNotificationsSettingTitle),
                subtitle: Text(l10n.pushNotificationsSettingDesc),
                value: _pushNotificationsEnabled,
                onChanged: _notificationBusy ? null : _togglePushNotifications,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: Text(l10n.eventRemindersSettingTitle),
                subtitle: Text(
                  reminderService.supportsLocalReminders
                      ? l10n.eventRemindersSettingDesc
                      : l10n.eventRemindersUnsupportedDesc,
                ),
                value:
                    reminderService.supportsLocalReminders &&
                    _eventRemindersEnabled,
                onChanged:
                    reminderService.supportsLocalReminders && !_notificationBusy
                    ? _toggleEventReminders
                    : null,
              ),
              const Divider(),
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
              if (supportsDynamicColors)
                SwitchListTile(
                  secondary: const Icon(Icons.palette_outlined),
                  title: Text(l10n.colorScheme),
                  subtitle: Text(
                    state.useDynamicColors
                        ? l10n.dynamicColors
                        : l10n.sggwColors,
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
              SwitchListTile(
                secondary: const Icon(Icons.skip_next_outlined),
                title: Text(l10n.skipTreasureHuntSettingTitle),
                subtitle: Text(l10n.skipTreasureHuntSettingDesc),
                value: state.skipTreasureHunt,
                onChanged: (value) {
                  context.read<SettingsCubit>().setSkipTreasureHunt(value);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.viewOnboarding),
                subtitle: Text(l10n.viewOnboardingDesc),
                onTap: () async {
                  final settingsCubit = context.read<SettingsCubit>();
                  if (context.mounted) {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OnboardingPage(
                          onComplete: () {
                            Navigator.of(context).pop();
                          },
                          settingsBox: settingsCubit.settingsBox,
                        ),
                      ),
                    );
                    settingsCubit.reloadFromStorage();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.privacyPolicy),
                subtitle: Text(l10n.privacyPolicyDesc),
                onTap: () => context.push('/privacy-policy'),
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
              const Divider(),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin'),
                onTap: () => context.push('/admin'),
              ),
            ],
          );
        },
      ),
    );
  }
}
