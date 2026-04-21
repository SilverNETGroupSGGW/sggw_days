import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_scan_code.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_event.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/pages/scan_history_page.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_bloc.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

IconData iconForPointType(PointType type) {
  return switch (type) {
    PointType.treasurePoint => Icons.emoji_events,
    PointType.pointOfInterest => Icons.place,
  };
}

Color colorForPointType(PointType type, ColorScheme colorScheme) {
  return switch (type) {
    PointType.treasurePoint => colorScheme.primary,
    PointType.pointOfInterest => colorScheme.secondary,
  };
}

class TreasureHuntPage extends StatefulWidget {
  const TreasureHuntPage({super.key});

  @override
  State<TreasureHuntPage> createState() => _TreasureHuntPageState();
}

class _TreasureHuntPageState extends State<TreasureHuntPage> {
  final MapController _mapController = MapController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
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
    _confettiController.dispose();
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
          // Show confetti + congratulation popup when a treasure point is scanned
          if (state.lastScannedPointId != null) {
            final scannedPoint = state.points
                .where((p) => p.id == state.lastScannedPointId)
                .firstOrNull;
            if (scannedPoint != null &&
                scannedPoint.type == PointType.treasurePoint) {
              _confettiController.play();
              _showPointCollectedDialog(context, scannedPoint);
            }
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

          final hasScanned = state.foundPointIds.isNotEmpty;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: sggwCenter,
                  initialZoom: 16.0,
                  minZoom: 14.0,
                  maxZoom: 19.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sggw.days',
                  ),
                  MarkerLayer(
                    markers: [
                      ...state.points
                          .where((p) => state.unlockedPointIds.contains(p.id))
                          .map((point) {
                            final isFound = state.foundPointIds.contains(
                              point.id,
                            );
                            final position = LatLng(
                              point.latitude,
                              point.longitude,
                            );
                            final colorScheme = Theme.of(context).colorScheme;
                            final typeColor = colorForPointType(
                              point.type,
                              colorScheme,
                            );
                            final isTracked = state.trackedPointId == point.id;
                            return Marker(
                              point: position,
                              width: 60,
                              height: 60,
                              child: GestureDetector(
                                onTap: () =>
                                    _showPointDetails(context, point, isFound),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: isTracked
                                          ? BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: typeColor.withValues(
                                                    alpha: 0.5,
                                                  ),
                                                  blurRadius: 12,
                                                  spreadRadius: 4,
                                                ),
                                              ],
                                            )
                                          : null,
                                      child: Icon(
                                        isFound
                                            ? Icons.check_circle
                                            : iconForPointType(point.type),
                                        color: isFound
                                            ? typeColor.withValues(alpha: 0.8)
                                            : typeColor,
                                        size: isTracked ? 38 : 32,
                                      ),
                                    ),
                                    if (_currentPosition != null && !isFound)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surface.withValues(
                                            alpha: 0.85,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
              ),
              // Confetti overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 1.5708,
                  blastDirectionality: BlastDirectionality.explosive,
                  maxBlastForce: 20,
                  minBlastForce: 8,
                  emissionFrequency: 0.05,
                  numberOfParticles: 25,
                  gravity: 0.1,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                    Colors.yellow,
                  ],
                ),
              ),
              if (!hasScanned)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.explore,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.tutorialTitle,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context)!.tutorialDesc,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'checklist_fab',
            onPressed: () => _showChecklist(context),
            child: const Icon(Icons.checklist),
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

  void _showChecklist(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final huntState = context.read<TreasureHuntBloc>().state;

    // Categorize points
    final pois = huntState.points
        .where((p) => p.type == PointType.pointOfInterest)
        .toList();
    final treasurePoints = huntState.sortedTreasurePoints;
    final foundIds = huntState.foundPointIds;
    final unlocked = huntState.unlockedPointIds;

    // Next unfound treasure point
    final unfoundTreasure = treasurePoints
        .where((p) => !foundIds.contains(p.id) && unlocked.contains(p.id))
        .toList();
    final nextTreasure = unfoundTreasure.isNotEmpty
        ? unfoundTreasure.first
        : null;
    final treasureRemaining = treasurePoints
        .where((p) => !foundIds.contains(p.id))
        .length;

    void trackAndClose(TreasurePoint point) {
      Navigator.pop(context);
      context.read<TreasureHuntBloc>().add(TrackPoint(point.id));
      _zoomToFitTracked(context, point, hasScanned: foundIds.isNotEmpty);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.checklist),
                  const SizedBox(width: 8),
                  Text(l10n.checklist, style: theme.textTheme.titleLarge),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Treasure Points section
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Text(
                      l10n.typeTreasurePoint,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorForPointType(
                          PointType.treasurePoint,
                          theme.colorScheme,
                        ),
                      ),
                    ),
                  ),
                  // Show found treasure points + next unfound one
                  ...treasurePoints
                      .where((p) => foundIds.contains(p.id))
                      .map(
                        (point) => _ChecklistTile(
                          icon: Icons.emoji_events,
                          color: colorForPointType(
                            PointType.treasurePoint,
                            theme.colorScheme,
                          ),
                          title: point.name,
                          isFound: true,
                          onTap: () => trackAndClose(point),
                        ),
                      ),
                  if (nextTreasure != null)
                    _ChecklistTile(
                      icon: Icons.emoji_events,
                      color: colorForPointType(
                        PointType.treasurePoint,
                        theme.colorScheme,
                      ),
                      title: nextTreasure.name,
                      subtitle: l10n.treasurePointsRemaining(treasureRemaining),
                      isFound: false,
                      onTap: () => trackAndClose(nextTreasure),
                    )
                  else if (treasurePoints.every(
                        (p) => foundIds.contains(p.id),
                      ) &&
                      treasurePoints.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.allTreasurePointsCollected,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  // Points of Interest section
                  if (pois.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 4),
                      child: Text(
                        l10n.typePointOfInterest,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorForPointType(
                            PointType.pointOfInterest,
                            theme.colorScheme,
                          ),
                        ),
                      ),
                    ),
                    ...pois.map(
                      (point) => _ChecklistTile(
                        icon: Icons.place,
                        color: colorForPointType(
                          PointType.pointOfInterest,
                          theme.colorScheme,
                        ),
                        title: point.name,
                        isFound: foundIds.contains(point.id),
                        onTap: () => trackAndClose(point),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        content: Text(l10n.allPointsFound, textAlign: TextAlign.center),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showPointCollectedDialog(BuildContext context, TreasurePoint point) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.emoji_events,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        title: Text(l10n.pointCollected),
        content: Text(
          l10n.pointCollectedDesc(point.name),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showPointDetails(context, point, true);
            },
            child: Text(l10n.seeDetails),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.continueScan),
          ),
        ],
      ),
    );
  }

  void _zoomToFitTracked(
    BuildContext context,
    TreasurePoint point, {
    required bool hasScanned,
  }) {
    final target = LatLng(point.latitude, point.longitude);
    if (_currentPosition != null) {
      final size = MediaQuery.sizeOf(context);
      final safePadding = MediaQuery.paddingOf(context);
      final bounds = LatLngBounds.fromPoints([_currentPosition!, target]);

      final leftPadding = (size.width * 0.14).clamp(72.0, 132.0).toDouble();
      final rightPadding = (size.width * 0.2).clamp(104.0, 180.0).toDouble();
      final topPadding =
          (size.height * (hasScanned ? 0.12 : 0.2))
              .clamp(104.0, 220.0)
              .toDouble() +
          safePadding.top;
      final bottomPadding =
          (size.height * 0.22).clamp(136.0, 240.0).toDouble() +
          safePadding.bottom;

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: EdgeInsets.fromLTRB(
            leftPadding,
            topPadding,
            rightPadding,
            bottomPadding,
          ),
          maxZoom: 16.75,
        ),
      );
    } else {
      _mapController.move(target, 17.0);
    }
  }

  void _showPointDetails(
    BuildContext context,
    TreasurePoint point,
    bool isFound,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    String? distanceText;
    if (_currentPosition != null) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        point.latitude,
        point.longitude,
      );
      distanceText = distance < 1000
          ? '${distance.round()} m'
          : '${(distance / 1000).toStringAsFixed(1)} km';
    }

    // Get related wikis and events
    final wikiState = context.read<WikiBloc>().state;
    final timetableState = context.read<TimetableBloc>().state;
    final relatedWikis = wikiState.articles
        .where((a) => a.treasurePointIds.contains(point.id))
        .toList();
    final relatedEvents = timetableState.events
        .where((e) => e.treasurePointIds.contains(point.id))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              iconForPointType(point.type),
              color: colorForPointType(point.type, theme.colorScheme),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(point.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(point.description),
              if (distanceText != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${l10n.distance}: $distanceText',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (isFound) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.pointFound,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              if (relatedWikis.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l10n.relatedWiki, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                ...relatedWikis.map(
                  (article) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.article,
                      size: 20,
                      color: theme.colorScheme.secondary,
                    ),
                    title: Text(
                      article.title,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
              if (relatedEvents.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l10n.relatedEvents, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                ...relatedEvents.map(
                  (event) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.event,
                      size: 20,
                      color: theme.colorScheme.tertiary,
                    ),
                    title: Text(event.title, style: theme.textTheme.bodyMedium),
                    subtitle: Text(
                      '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
            unlockedPointIds: context
                .read<TreasureHuntBloc>()
                .state
                .unlockedPointIds,
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
  final Set<String> unlockedPointIds;
  final Function(String) onCodeScanned;

  const _QRScannerPage({
    required this.currentPosition,
    required this.treasurePoints,
    required this.unlockedPointIds,
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

  String? _extractPointId(String code) {
    return tryExtractTreasurePointId(code);
  }

  TreasurePoint? _findPoint(String code) {
    final pointId = _extractPointId(code);
    if (pointId != null) {
      return treasurePoints.where((p) => p.id == pointId).firstOrNull;
    }
    // Legacy: match by raw qrCode string
    return treasurePoints.where((p) => p.qrCode == code).firstOrNull;
  }

  bool _isNearTreasurePoint(String qrCode) {
    if (kDebugMode) return true;

    const double maxDistance = 50.0; // meters

    final point = _findPoint(qrCode);
    if (point != null) {
      final distance = _calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        point.latitude,
        point.longitude,
      );
      return distance <= maxDistance;
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
              final point = _findPoint(code);

              if (point == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.invalidQrCode),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              } else if (!unlockedPointIds.contains(point.id)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.pointLocked),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              } else if (_isNearTreasurePoint(code)) {
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

class _ChecklistTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool isFound;
  final VoidCallback? onTap;

  const _ChecklistTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.isFound,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(
        isFound ? Icons.check_circle : icon,
        color: isFound ? color.withValues(alpha: 0.5) : color,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          decoration: isFound ? TextDecoration.lineThrough : null,
          color: isFound
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
              : null,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
    );
  }
}
