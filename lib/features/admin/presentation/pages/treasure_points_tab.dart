import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sggw_days/core/icons/material_symbol_catalog.dart';
import 'package:sggw_days/core/icons/material_symbol_field.dart';
import 'package:sggw_days/features/admin/presentation/poster_generator_uri.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_event.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_state.dart';
import 'package:sggw_days/features/admin/presentation/widgets/invalid_entries_banner.dart';
import 'package:sggw_days/features/admin/presentation/widgets/location_picker_map.dart';
import 'package:sggw_days/features/admin/presentation/widgets/qr_code_widget.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/point_type_presentation.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class TreasurePointsTab extends StatelessWidget {
  const TreasurePointsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading &&
            state.treasurePoints.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            InvalidEntriesBanner(
              entries: state.invalidTreasurePoints,
              collection: 'treasure_points',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Point'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showReorderDialog(context, state.treasurePoints),
                    icon: const Icon(Icons.reorder),
                    label: Text(l10n.reorderPoints),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.treasurePoints.isEmpty
                  ? Center(child: Text('No ${l10n.points.toLowerCase()} yet'))
                  : ListView.builder(
                      itemCount: state.treasurePoints.length,
                      itemBuilder: (context, index) {
                        final point = state.treasurePoints[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ExpansionTile(
                            leading: Icon(iconForPoint(point)),
                            title: Text(point.name),
                            subtitle: Text(labelForPointType(point.type, l10n)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showAddEditDialog(context, point: point),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _showDeleteDialog(context, point),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Description: ${point.description}'),
                                    const SizedBox(height: 8),
                                    if (point.imageUrl != null) ...[
                                      Text('Image: ${point.imageUrl}'),
                                      const SizedBox(height: 8),
                                    ],
                                    if (point.iconName != null) ...[
                                      Text('Symbol: ${point.iconName}'),
                                      const SizedBox(height: 8),
                                    ],
                                    Text('QR Code: ${point.qrCode}'),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Location: ${point.latitude}, ${point.longitude}',
                                    ),
                                    const SizedBox(height: 16),
                                    if (point.qrCode.isNotEmpty)
                                      Column(
                                        children: [
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                color: Colors.white,
                                              ),
                                              child: QrCodeWidget(
                                                data: point.qrCode,
                                                size: 200,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Center(
                                            child: FilledButton.icon(
                                              onPressed: () =>
                                                  _openCheckpointPoster(
                                                    context,
                                                    point,
                                                  ),
                                              icon: const Icon(
                                                Icons.local_printshop_outlined,
                                              ),
                                              label: const Text(
                                                'Poster: STREFA ZADAŃ',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openCheckpointPoster(
    BuildContext context,
    TreasurePoint point,
  ) async {
    final uri = posterGeneratorUri(
      checkpointUrl: point.qrCode,
      pointName: point.name,
      openCheckpointPoster: true,
    );
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (opened || !context.mounted) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: uri.toString()));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Poster generator link copied.')),
    );
  }

  void _showAddEditDialog(BuildContext context, {TreasurePoint? point}) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: point?.name ?? '');
    final descController = TextEditingController(
      text: point?.description ?? '',
    );
    final imageUrlController = TextEditingController(
      text: point?.imageUrl ?? '',
    );
    final latController = TextEditingController(
      text: point?.latitude.toString() ?? '',
    );
    final lonController = TextEditingController(
      text: point?.longitude.toString() ?? '',
    );
    PointType selectedType = point?.type ?? PointType.pointOfInterest;
    final iconNameController = TextEditingController(
      text: normalizeMaterialSymbolName(point?.iconName) ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    point == null ? 'Add Point' : 'Edit Point',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SegmentedButton<PointType>(
                            segments: [
                              ButtonSegment(
                                value: PointType.treasurePoint,
                                label: Text(l10n.typeTreasurePoint),
                                icon: Icon(
                                  iconForPointType(PointType.treasurePoint),
                                ),
                              ),
                              ButtonSegment(
                                value: PointType.pointOfInterest,
                                label: Text(l10n.typePointOfInterest),
                                icon: Icon(
                                  iconForPointType(PointType.pointOfInterest),
                                ),
                              ),
                            ],
                            selected: {selectedType},
                            onSelectionChanged: (selected) {
                              setState(() => selectedType = selected.first);
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                          ),
                          TextField(
                            controller: descController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                            ),
                            maxLines: 2,
                          ),
                          TextField(
                            controller: imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Image URL (optional)',
                            ),
                          ),
                          const SizedBox(height: 8),
                          MaterialSymbolField(
                            controller: iconNameController,
                            fallbackIcon: Icons.place,
                            labelText: 'Fallback Material Symbol',
                            emptyHelperText:
                                'Leave empty to use the default point icon.',
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: latController,
                                  decoration: const InputDecoration(
                                    labelText: 'Latitude',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: lonController,
                                  decoration: const InputDecoration(
                                    labelText: 'Longitude',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final permission =
                                    await Geolocator.checkPermission();
                                if (permission == LocationPermission.denied ||
                                    permission ==
                                        LocationPermission.deniedForever) {
                                  await Geolocator.requestPermission();
                                }
                                final position =
                                    await Geolocator.getCurrentPosition();
                                latController.text = position.latitude
                                    .toString();
                                lonController.text = position.longitude
                                    .toString();
                              } catch (e) {
                                if (dialogContext.mounted) {
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error getting location: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.my_location),
                            label: const Text('Use Current Location'),
                          ),
                          const SizedBox(height: 12),
                          LocationPickerMap(
                            initialLocation: point != null
                                ? LatLng(point.latitude, point.longitude)
                                : null,
                            onLocationSelected: (latLng) {
                              latController.text = latLng.latitude
                                  .toStringAsFixed(6);
                              lonController.text = latLng.longitude
                                  .toStringAsFixed(6);
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final description = descController.text.trim();
                          final imageUrl = imageUrlController.text.trim();
                          final latitude = double.tryParse(
                            latController.text.trim(),
                          );
                          final longitude = double.tryParse(
                            lonController.text.trim(),
                          );

                          if (name.isEmpty || description.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Name and description are required.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (latitude == null ||
                              latitude < -90 ||
                              latitude > 90) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Latitude must be between -90 and 90.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (longitude == null ||
                              longitude < -180 ||
                              longitude > 180) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Longitude must be between -180 and 180.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (imageUrl.isNotEmpty) {
                            final imageUri = Uri.tryParse(imageUrl);
                            final isValidHttpsImage =
                                imageUri != null &&
                                imageUri.scheme == 'https' &&
                                imageUri.host.isNotEmpty;
                            if (!isValidHttpsImage) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Image URL must use HTTPS.'),
                                ),
                              );
                              return;
                            }
                          }
                          final requestedIconName = iconNameController.text
                              .trim();
                          final iconName = normalizeMaterialSymbolName(
                            requestedIconName,
                          );
                          if (requestedIconName.isNotEmpty &&
                              iconName == null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Choose a valid Material Symbol name or leave it empty.',
                                ),
                              ),
                            );
                            return;
                          }

                          final newPoint = TreasurePoint(
                            id: point?.id ?? '',
                            name: name,
                            description: description,
                            latitude: latitude,
                            longitude: longitude,
                            qrCode: point?.qrCode ?? '',
                            imageUrl: imageUrl.isEmpty ? null : imageUrl,
                            iconName: iconName,
                            type: selectedType,
                            order: point?.order ?? 0,
                          );

                          if (point == null) {
                            context.read<AdminBloc>().add(
                              CreateTreasurePoint(newPoint),
                            );
                          } else {
                            context.read<AdminBloc>().add(
                              UpdateTreasurePoint(newPoint),
                            );
                          }

                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(point == null ? 'Add' : 'Update'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TreasurePoint point) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Point'),
        content: Text('Are you sure you want to delete "${point.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(DeleteTreasurePoint(point.id));
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReorderDialog(BuildContext context, List<TreasurePoint> allPoints) {
    final l10n = AppLocalizations.of(context)!;
    // Only reorder treasure points
    final treasurePoints =
        allPoints.where((p) => p.type == PointType.treasurePoint).toList()
          ..sort((a, b) => a.order.compareTo(b.order));

    if (treasurePoints.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) => _ReorderDialog(
        treasurePoints: treasurePoints,
        l10n: l10n,
        onSave: (reordered) {
          context.read<AdminBloc>().add(ReorderTreasurePoints(reordered));
        },
      ),
    );
  }
}

class _ReorderDialog extends StatefulWidget {
  final List<TreasurePoint> treasurePoints;
  final AppLocalizations l10n;
  final ValueChanged<List<TreasurePoint>> onSave;

  const _ReorderDialog({
    required this.treasurePoints,
    required this.l10n,
    required this.onSave,
  });

  @override
  State<_ReorderDialog> createState() => _ReorderDialogState();
}

class _ReorderDialogState extends State<_ReorderDialog> {
  late List<TreasurePoint> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.treasurePoints);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.l10n.reorderPoints,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _items.removeAt(oldIndex);
                      _items.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final point = _items[index];
                    return ListTile(
                      key: ValueKey(point.id),
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(point.name),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(widget.l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      widget.onSave(_items);
                      Navigator.pop(context);
                    },
                    child: Text(widget.l10n.ok),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
