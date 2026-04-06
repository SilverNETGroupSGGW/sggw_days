import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sggw_days/features/admin/data/repositories/admin_repository.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_event.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_state.dart';
import 'package:sggw_days/features/admin/presentation/widgets/invalid_entries_banner.dart';
import 'package:sggw_days/features/admin/presentation/widgets/treasure_point_selector.dart';
import 'package:sggw_days/features/timetable/data/models/timetable_event.dart';

class TimetableEventsTab extends StatelessWidget {
  const TimetableEventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
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
              child: state.timetableEvents.isEmpty
                  ? const Center(child: Text('No timetable events yet'))
                  : ListView.builder(
                      itemCount: state.timetableEvents.length,
                      itemBuilder: (context, index) {
                        final event = state.timetableEvents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.event),
                            title: Text(event.title),
                            subtitle: Text(
                              '${event.location}\n${event.startTime.toLocal()} - ${event.endTime.toLocal()}',
                            ),
                            isThreeLine: true,
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
        builder: (context, setState) => AlertDialog(
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
                      String? imageUrl = imageUrlController.text.isEmpty
                          ? null
                          : imageUrlController.text;

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

                      final tags = tagsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      final newEvent = TimetableEvent(
                        id: event?.id ?? '',
                        title: titleController.text,
                        description: descController.text,
                        startTime: startTime,
                        endTime: endTime,
                        location: locationController.text,
                        imageUrl: imageUrl,
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

  void _showDeleteDialog(BuildContext context, TimetableEvent event) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
