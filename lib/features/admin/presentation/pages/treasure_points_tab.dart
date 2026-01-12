import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_event.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_state.dart';
import 'package:sggw_days/features/admin/presentation/widgets/qr_code_widget.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

class TreasurePointsTab extends StatelessWidget {
  const TreasurePointsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading &&
            state.treasurePoints.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Treasure Point'),
              ),
            ),
            Expanded(
              child: state.treasurePoints.isEmpty
                  ? const Center(child: Text('No treasure points yet'))
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
                            leading: const Icon(Icons.location_on),
                            title: Text(point.name),
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
                                    Text('QR Code: ${point.qrCode}'),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Location: ${point.latitude}, ${point.longitude}',
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: QrCodeWidget(
                                          data: point.qrCode,
                                          size: 200,
                                        ),
                                      ),
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

  void _showAddEditDialog(BuildContext context, {TreasurePoint? point}) {
    final nameController = TextEditingController(text: point?.name ?? '');
    final descController = TextEditingController(
      text: point?.description ?? '',
    );
    final latController = TextEditingController(
      text: point?.latitude.toString() ?? '',
    );
    final lonController = TextEditingController(
      text: point?.longitude.toString() ?? '',
    );
    final qrCodeController = TextEditingController(text: point?.qrCode ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          point == null ? 'Add Treasure Point' : 'Edit Treasure Point',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: latController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: lonController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied ||
                        permission == LocationPermission.deniedForever) {
                      await Geolocator.requestPermission();
                    }
                    final position = await Geolocator.getCurrentPosition();
                    latController.text = position.latitude.toString();
                    lonController.text = position.longitude.toString();
                  } catch (e) {
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('Error getting location: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qrCodeController,
                      decoration: const InputDecoration(
                        labelText: 'QR Code Data',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Generate Random QR Data',
                    onPressed: () {
                      const chars =
                          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                      final rnd = Random();
                      final randomString = String.fromCharCodes(
                        Iterable.generate(
                          16,
                          (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
                        ),
                      );
                      qrCodeController.text = 'sggw_days_$randomString';
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPoint = TreasurePoint(
                id: point?.id ?? '',
                name: nameController.text,
                description: descController.text,
                latitude: double.tryParse(latController.text) ?? 0,
                longitude: double.tryParse(lonController.text) ?? 0,
                qrCode: qrCodeController.text,
              );

              if (point == null) {
                context.read<AdminBloc>().add(CreateTreasurePoint(newPoint));
              } else {
                context.read<AdminBloc>().add(UpdateTreasurePoint(newPoint));
              }

              Navigator.of(dialogContext).pop();
            },
            child: Text(point == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TreasurePoint point) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Treasure Point'),
        content: Text('Are you sure you want to delete "${point.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
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
}
