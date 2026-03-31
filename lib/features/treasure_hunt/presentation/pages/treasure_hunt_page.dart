import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sggw_days/core/theme/app_theme.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_event.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/pages/scan_history_page.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class TreasureHuntPage extends StatefulWidget {
  const TreasureHuntPage({super.key});

  @override
  State<TreasureHuntPage> createState() => _TreasureHuntPageState();
}

class _TreasureHuntPageState extends State<TreasureHuntPage> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  // SGGW coordinates
  static const LatLng sggwCenter = LatLng(52.1598, 21.0463);

  @override
  void initState() {
    super.initState();
    context.read<TreasureHuntBloc>().add(const LoadTreasurePoints());
    _initLocationService();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocationService() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        return;
      }
    }

    // Get initial position
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (_) {
      // Ignore errors for now
    }

    // Listen for updates
    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          if (mounted) {
            setState(() {
              _currentPosition = LatLng(position.latitude, position.longitude);
            });
          }
        });
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
              final total = state.points.length;
              final found = state.points
                  .where((p) => state.foundPointIds.contains(p.id))
                  .length;
              final progress = total == 0 ? 0.0 : found / total;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$found/$total',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanHistoryPage(),
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
          // Check if all points found
          if (state.points.isNotEmpty &&
              state.foundPointIds.length == state.points.length &&
              state.status == TreasureHuntStatus.success) {
            _showCelebration(context);
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
                markers: [
                  ...state.points.map((point) {
                    final isFound = state.foundPointIds.contains(point.id);
                    final position = LatLng(point.latitude, point.longitude);
                    return Marker(
                      point: position,
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () => _showPointDetails(context, point, isFound),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFound ? Icons.check_circle : Icons.location_on,
                              color: isFound
                                  ? AppColors.primaryGreen
                                  : AppColors.red,
                              size: 32,
                            ),
                            if (_currentPosition != null && !isFound)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _formatDistance(
                                    Geolocator.distanceBetween(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                      point.latitude,
                                      point.longitude,
                                    ),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(fontSize: 9),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 40,
                      height: 40,
                      child: const _UserLocationMarker(),
                    ),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentPosition != null)
            FloatingActionButton.small(
              heroTag: 'my_location_fab',
              onPressed: () {
                _mapController.move(_currentPosition!, 16.0);
              },
              child: const Icon(Icons.my_location),
            ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'qr_scanner_fab',
            onPressed: () => _openQRScanner(context),
            child: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  void _showCelebration(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.emoji_events,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        title: Text(l10n.congratulations),
        content: Text(
          l10n.allPointsFound,
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showPointDetails(BuildContext context, dynamic point, bool isFound) {
    final l10n = AppLocalizations.of(context)!;
    String? distanceText;
    if (_currentPosition != null) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        point.latitude as double,
        point.longitude as double,
      );
      distanceText = distance < 1000
          ? '${distance.round()} m'
          : '${(distance / 1000).toStringAsFixed(1)} km';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(point.name as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(point.description as String),
            if (distanceText != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.distance}: $distanceText',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
            if (isFound) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    l10n.pointFound,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _openQRScanner(BuildContext context) async {
    // Get current location
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _QRScannerPage(
            currentPosition: position,
            treasurePoints: context.read<TreasureHuntBloc>().state.points,
            onCodeScanned: (code) {
              context.read<TreasureHuntBloc>().add(ScanQRCode(code));
              Navigator.pop(context);
            },
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to get location: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _QRScannerPage extends StatelessWidget {
  final Position currentPosition;
  final List<TreasurePoint> treasurePoints;
  final Function(String) onCodeScanned;

  const _QRScannerPage({
    required this.currentPosition,
    required this.treasurePoints,
    required this.onCodeScanned,
  });

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  bool _isNearTreasurePoint(String qrCode) {
    const double maxDistance = 50.0; // meters

    for (final point in treasurePoints) {
      if (point.qrCode == qrCode) {
        final distance = _calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          point.latitude,
          point.longitude,
        );
        return distance <= maxDistance;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanQr)),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              final code = barcode.rawValue!;

              if (_isNearTreasurePoint(code)) {
                onCodeScanned(code);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.mustBeCloser),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
              break;
            }
          }
        },
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
