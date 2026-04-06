import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/features/admin/data/models/invalid_entry.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_event.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class InvalidEntriesBanner extends StatelessWidget {
  final List<InvalidEntry> entries;
  final String collection;

  const InvalidEntriesBanner({
    super.key,
    required this.entries,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final fixableEntries = entries.where((e) => e.fixedData != null).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.errorContainer,
      child: ExpansionTile(
        leading: Badge(
          label: Text('${entries.length}'),
          child: Icon(Icons.warning_amber, color: colorScheme.error),
        ),
        title: Text(
          l10n.adminInvalidEntries(entries.length),
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
        subtitle: Text(
          l10n.adminInvalidEntriesDesc,
          style: TextStyle(
            color: colorScheme.onErrorContainer.withValues(alpha: 0.7),
          ),
        ),
        children: [
          if (fixableEntries.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<AdminBloc>().add(
                      FixAllInvalidEntries(collection),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.adminAllEntriesFixed)),
                    );
                  },
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(l10n.adminFixAll),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                ),
              ),
            ),
          ...entries.map(
            (entry) => _InvalidEntryTile(entry: entry, collection: collection),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InvalidEntryTile extends StatelessWidget {
  final InvalidEntry entry;
  final String collection;

  const _InvalidEntryTile({required this.entry, required this.collection});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(
        entry.rawData['name'] as String? ??
            entry.rawData['title'] as String? ??
            entry.id,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
      subtitle: Text(
        entry.issues.join('\n'),
        style: TextStyle(
          color: colorScheme.onErrorContainer.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (entry.fixedData != null)
            IconButton(
              icon: const Icon(Icons.preview),
              tooltip: l10n.adminFixPreviewTitle,
              onPressed: () => _showFixPreview(context, entry),
            ),
          if (entry.fixedData != null)
            IconButton(
              icon: Icon(Icons.build, color: colorScheme.error),
              tooltip: l10n.adminFixEntry,
              onPressed: () {
                context.read<AdminBloc>().add(
                  FixInvalidEntry(
                    collection: collection,
                    docId: entry.id,
                    fixedData: entry.fixedData!,
                  ),
                );
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.adminEntryFixed)));
              },
            ),
          IconButton(
            icon: Icon(Icons.delete, color: colorScheme.error),
            tooltip: l10n.adminDeleteEntry,
            onPressed: () => _showDeleteDialog(context, entry),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, InvalidEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminDeleteEntry),
        content: Text(
          'Delete entry "${entry.rawData['name'] ?? entry.rawData['title'] ?? entry.id}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              switch (collection) {
                case 'treasure_points':
                  context.read<AdminBloc>().add(DeleteTreasurePoint(entry.id));
                case 'wiki_articles':
                  context.read<AdminBloc>().add(DeleteWikiArticle(entry.id));
                case 'timetable_events':
                  context.read<AdminBloc>().add(DeleteTimetableEvent(entry.id));
              }
            },
            child: Text(l10n.adminDeleteEntry),
          ),
        ],
      ),
    );
  }

  void _showFixPreview(BuildContext context, InvalidEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    const encoder = JsonEncoder.withIndent('  ');
    final rawDisplay = Map<String, dynamic>.from(entry.rawData)..remove('id');
    final rawJson = encoder.convert(rawDisplay);
    final fixedJson = encoder.convert(entry.fixedData);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminFixPreviewTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.adminRawData,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    rawJson,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.adminFixedData,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    fixedJson,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Issues:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                ...entry.issues.map(
                  (issue) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.arrow_right,
                          size: 16,
                          color: colorScheme.error,
                        ),
                        Expanded(
                          child: Text(issue, style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminBloc>().add(
                FixInvalidEntry(
                  collection: collection,
                  docId: entry.id,
                  fixedData: entry.fixedData!,
                ),
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.adminEntryFixed)));
            },
            child: Text(l10n.adminFixConfirm),
          ),
        ],
      ),
    );
  }
}
