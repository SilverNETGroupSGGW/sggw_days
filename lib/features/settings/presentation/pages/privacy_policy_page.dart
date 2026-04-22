import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
            tooltip: l10n.goHome,
          ),
        ],
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      size: 36,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.privacyPolicy,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.privacyPolicyIntro,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.privacyPolicyLastUpdated,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PolicySection(
              icon: Icons.data_usage_outlined,
              title: l10n.privacyPolicySectionCollectedTitle,
              intro: l10n.privacyPolicyCollectedIntro,
              items: [
                l10n.privacyPolicyCollectedCamera,
                l10n.privacyPolicyCollectedLocation,
                l10n.privacyPolicyCollectedStorage,
                l10n.privacyPolicyCollectedAdmin,
              ],
            ),
            const SizedBox(height: 16),
            _PolicySection(
              icon: Icons.task_alt_outlined,
              title: l10n.privacyPolicySectionUsageTitle,
              intro: l10n.privacyPolicyUsageIntro,
              items: [
                l10n.privacyPolicyUsageTreasureHunt,
                l10n.privacyPolicyUsageAppState,
                l10n.privacyPolicyUsageAdmin,
              ],
            ),
            const SizedBox(height: 16),
            _PolicySection(
              icon: Icons.cloud_outlined,
              title: l10n.privacyPolicySectionSharingTitle,
              intro: l10n.privacyPolicySharingIntro,
              items: [
                l10n.privacyPolicySharingFirebase,
                l10n.privacyPolicySharingLegal,
              ],
            ),
            const SizedBox(height: 16),
            _PolicySection(
              icon: Icons.tune_outlined,
              title: l10n.privacyPolicySectionChoicesTitle,
              intro: l10n.privacyPolicyChoicesIntro,
              items: [
                l10n.privacyPolicyChoicesPermissions,
                l10n.privacyPolicyChoicesAdmin,
                l10n.privacyPolicyChoicesDevice,
              ],
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.mail_outline, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.privacyPolicySectionContactTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.privacyPolicyContactIntro,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.privacyPolicyContactDetails,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.privacyPolicyContactNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.tonalIcon(
                      onPressed: () => context.go('/settings'),
                      icon: const Icon(Icons.settings_outlined),
                      label: Text(l10n.settings),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.icon,
    required this.title,
    required this.intro,
    required this.items,
  });

  final IconData icon;
  final String title;
  final String intro;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              intro,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 16),
            for (final item in items) ...[
              _PolicyBullet(text: item),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _PolicyBullet extends StatelessWidget {
  const _PolicyBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Icon(Icons.circle, size: 8, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}
