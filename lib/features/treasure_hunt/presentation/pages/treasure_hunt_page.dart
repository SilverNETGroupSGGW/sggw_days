import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sggw_days/core/theme/app_theme.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_event.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class TreasureHuntPage extends StatefulWidget {
  const TreasureHuntPage({super.key});

  @override
  State<TreasureHuntPage> createState() => _TreasureHuntPageState();
}

class _TreasureHuntPageState extends State<TreasureHuntPage> {
  final MapController _mapController = MapController();

  // SGGW coordinates
  static const LatLng sggwCenter = LatLng(52.1598, 21.0463);

  @override
  void initState() {
    super.initState();
    context.read<TreasureHuntBloc>().add(const LoadTreasurePoints());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.treasureHunt),
        actions: [
          BlocBuilder<TreasureHuntBloc, TreasureHuntState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    l10n.score(state.totalScore),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TreasureHuntBloc, TreasureHuntState>(
        listener: (context, state) {
          if (state.status == TreasureHuntStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == TreasureHuntStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: sggwCenter,
              initialZoom: 16.0,
              minZoom: 14.0,
              maxZoom: 19.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sggw.days',
              ),
              MarkerLayer(
                markers: state.points.map((point) {
                  final isFound = state.foundPointIds.contains(point.id);
                  final position = LatLng(point.latitude, point.longitude);
                  return Marker(
                    point: position,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showPointDetails(context, point, isFound),
                      child: Icon(
                        isFound ? Icons.check_circle : Icons.location_on,
                        color: isFound
                            ? AppColors.primaryGreen
                            : AppColors.red,
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openQRScanner(context),
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  void _showPointDetails(BuildContext context, dynamic point, bool isFound) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(point.name as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(point.description as String),
            const SizedBox(height: 16),
            Text('${AppLocalizations.of(context)!.points}: ${point.points}'),
            if (isFound)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.pointFound,
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _openQRScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QRScannerPage(
          onCodeScanned: (code) {
            context.read<TreasureHuntBloc>().add(ScanQRCode(code));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _QRScannerPage extends StatelessWidget {
  final Function(String) onCodeScanned;

  const _QRScannerPage({required this.onCodeScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scanQr),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              onCodeScanned(barcode.rawValue!);
              break;
            }
          }
        },
      ),
    );
  }
}
