import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sggw_days/core/icons/material_symbol_catalog.dart';
import 'package:sggw_days/core/icons/material_symbol_field.dart';
import 'package:sggw_days/core/widgets/app_alert_dialog.dart';
import 'package:sggw_days/features/admin/data/repositories/admin_repository.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_event.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_state.dart';
import 'package:sggw_days/features/admin/presentation/poster_generator_uri.dart';
import 'package:sggw_days/features/admin/presentation/widgets/invalid_entries_banner.dart';
import 'package:sggw_days/features/admin/presentation/widgets/qr_code_widget.dart';
import 'package:sggw_days/features/admin/presentation/widgets/treasure_point_selector.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';
import 'package:url_launcher/url_launcher.dart';

class TimetableEventsTab extends StatelessWidget {
  const TimetableEventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        final sortedEvents = List<TimetableEvent>.from(state.timetableEvents)
          ..sort(_compareTimetableEvents);

        if (state.status == AdminStatus.loading &&
            state.timetableEvents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            InvalidEntriesBanner(
              entries: state.invalidTimetableEvents,
              collection: 'timetable_events',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Timetable Event'),
              ),
            ),
            Expanded(
              child: sortedEvents.isEmpty
                  ? const Center(child: Text('No timetable events yet'))
                  : ListView.builder(
                      itemCount: sortedEvents.length,
                      itemBuilder: (context, index) {
                        final event = sortedEvents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ExpansionTile(
                            leading: Icon(
                              materialSymbolForName(
                                event.iconName,
                                fallback: Icons.event,
                              ),
                            ),
                            title: Text(event.title),
                            subtitle: Text(
                              '${event.location}\n${event.startTime.toLocal()} - ${event.endTime.toLocal()}',
                            ),
                            initiallyExpanded: false,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showAddEditDialog(context, event: event),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _showDeleteDialog(context, event),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Description: ${event.description}'),
                                    const SizedBox(height: 8),
                                    if (event.imageUrl != null) ...[
                                      Text('Image: ${event.imageUrl}'),
                                      const SizedBox(height: 8),
                                    ],
                                    if (event.iconName != null) ...[
                                      Text('Symbol: ${event.iconName}'),
                                      const SizedBox(height: 8),
                                    ],
                                    if (event.tags.isNotEmpty) ...[
                                      Text('Tags: ${event.tags.join(', ')}'),
                                      const SizedBox(height: 8),
                                    ],
                                    if (event.treasurePointIds.isNotEmpty) ...[
                                      Text(
                                        'Related points: ${event.treasurePointIds.join(', ')}',
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    const Text('Check-in code:'),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SelectableText(event.id),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _copyEventCode(context, event.id),
                                          icon: const Icon(Icons.copy_all),
                                          tooltip: 'Copy check-in code',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (event.id.isNotEmpty)
                                      Column(
                                        children: [
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                color: Colors.white,
                                              ),
                                              child: QrCodeWidget(
                                                data: event.id,
                                                size: 200,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Center(
                                            child: FilledButton.icon(
                                              onPressed: () => _openEventPoster(
                                                context,
                                                event,
                                              ),
                                              icon: const Icon(
                                                Icons.local_printshop_outlined,
                                              ),
                                              label: const Text(
                                                'Event check-in poster',
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

  int _compareTimetableEvents(TimetableEvent a, TimetableEvent b) {
    final start = a.startTime.compareTo(b.startTime);
    if (start != 0) return start;

    final end = a.endTime.compareTo(b.endTime);
    if (end != 0) return end;

    final title = a.title.compareTo(b.title);
    if (title != 0) return title;

    return a.id.compareTo(b.id);
  }

  void _showAddEditDialog(BuildContext context, {TimetableEvent? event}) {
    final titleController = TextEditingController(text: event?.title ?? '');
    final descController = TextEditingController(
      text: event?.description ?? '',
    );
    final locationController = TextEditingController(
      text: event?.location ?? '',
    );
    final imageUrlController = TextEditingController(
      text: event?.imageUrl ?? '',
    );
    final tagsController = TextEditingController(
      text: event?.tags.join(', ') ?? '',
    );
    final iconNameController = TextEditingController(
      text: normalizeMaterialSymbolName(event?.iconName) ?? '',
    );

    DateTime startTime = event?.startTime ?? DateTime.now();
    DateTime endTime =
        event?.endTime ?? DateTime.now().add(const Duration(hours: 1));
    List<String> selectedPointIds = List<String>.from(
      event?.treasurePointIds ?? [],
    );

    bool useImageUpload = false;
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AppAlertDialog(
          title: Text(
            event == null ? 'Add Timetable Event' : 'Edit Timetable Event',
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Image URL'),
                      const Spacer(),
                      Switch(
                        value: useImageUpload,
                        onChanged: (value) {
                          setState(() => useImageUpload = value);
                        },
                      ),
                      const Text('Upload Image'),
                    ],
                  ),
                  if (!useImageUpload)
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL (optional)',
                      ),
                    )
                  else
                    Column(
                      children: [
                        if (selectedImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                selectedImageBytes!,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedImageName ?? 'No image selected',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (picked != null) {
                                  final bytes = await picked.readAsBytes();
                                  setState(() {
                                    selectedImageBytes = bytes;
                                    selectedImageName = picked.name;
                                  });
                                }
                              },
                              icon: const Icon(Icons.upload),
                              label: const Text('Choose Image'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  MaterialSymbolField(
                    controller: iconNameController,
                    fallbackIcon: Icons.event,
                    labelText: 'Fallback Material Symbol',
                    emptyHelperText:
                        'Leave empty to use the default event icon.',
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma-separated)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TreasurePointSelector(
                    availablePoints: dialogContext
                        .read<AdminBloc>()
                        .state
                        .treasurePoints,
                    selectedIds: selectedPointIds,
                    onChanged: (ids) {
                      setState(() => selectedPointIds = ids);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(startTime.toLocal().toString()),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(startTime),
                        );
                        if (time != null) {
                          setState(() {
                            startTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                            if (startTime.isAfter(endTime)) {
                              endTime = startTime.add(const Duration(hours: 1));
                            }
                          });
                        }
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(endTime.toLocal().toString()),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(endTime),
                        );
                        if (time != null) {
                          setState(() {
                            endTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      final title = titleController.text.trim();
                      final description = descController.text.trim();
                      final location = locationController.text.trim();

                      if (title.isEmpty ||
                          description.isEmpty ||
                          location.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Title, description, and location are required.',
                            ),
                          ),
                        );
                        return;
                      }

                      if (!endTime.isAfter(startTime)) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'End time must be after the start time.',
                            ),
                          ),
                        );
                        return;
                      }

                      String? imageUrl = imageUrlController.text.trim().isEmpty
                          ? null
                          : imageUrlController.text.trim();

                      if (imageUrl != null) {
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

                      if (useImageUpload &&
                          selectedImageBytes != null &&
                          selectedImageName != null) {
                        setState(() => isUploading = true);
                        try {
                          final repo = dialogContext.read<AdminRepository>();
                          imageUrl = await repo.uploadImage(
                            imageBytes: selectedImageBytes!,
                            fileName:
                                '${DateTime.now().millisecondsSinceEpoch}_$selectedImageName',
                            folder: 'event_images',
                          );
                        } catch (e) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Image upload failed: $e'),
                                backgroundColor: Theme.of(
                                  dialogContext,
                                ).colorScheme.error,
                              ),
                            );
                          }
                          setState(() => isUploading = false);
                          return;
                        }
                        setState(() => isUploading = false);
                      }

                      if (!dialogContext.mounted) return;

                      final tags = tagsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      final requestedIconName = iconNameController.text.trim();
                      final iconName = normalizeMaterialSymbolName(
                        requestedIconName,
                      );
                      if (requestedIconName.isNotEmpty && iconName == null) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Choose a valid Material Symbol name or leave it empty.',
                            ),
                          ),
                        );
                        return;
                      }

                      final newEvent = TimetableEvent(
                        id: event?.id ?? '',
                        title: title,
                        description: description,
                        startTime: startTime,
                        endTime: endTime,
                        location: location,
                        imageUrl: imageUrl,
                        iconName: iconName,
                        tags: tags,
                        treasurePointIds: selectedPointIds,
                      );

                      if (!dialogContext.mounted) return;

                      if (event == null) {
                        dialogContext.read<AdminBloc>().add(
                          CreateTimetableEvent(newEvent),
                        );
                      } else {
                        dialogContext.read<AdminBloc>().add(
                          UpdateTimetableEvent(newEvent),
                        );
                      }

                      Navigator.of(dialogContext).pop();
                    },
              child: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(event == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyEventCode(BuildContext context, String eventCode) async {
    await Clipboard.setData(ClipboardData(text: eventCode));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Check-in code copied.')));
  }

  Future<void> _openEventPoster(
    BuildContext context,
    TimetableEvent event,
  ) async {
    final uri = posterGeneratorUri(
      eventCode: event.id,
      eventTitle: event.title,
      openEventPoster: true,
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

  void _showDeleteDialog(BuildContext context, TimetableEvent event) {
    showDialog(
      context: context,
      builder: (dialogContext) => AppAlertDialog(
        title: const Text('Delete Timetable Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(DeleteTimetableEvent(event.id));
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
}
