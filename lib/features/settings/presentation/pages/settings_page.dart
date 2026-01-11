import 'package:flutter/material.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: const Text('Polski'),
            onTap: () {
              // TODO: Change language
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.theme),
            subtitle: const Text('System'),
            onTap: () {
              // TODO: Change theme
            },
          ),
        ],
      ),
    );
  }
}
