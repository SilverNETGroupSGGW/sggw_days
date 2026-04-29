import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sggw_days/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sggw_days/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/marker_cluster.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_bloc.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_event.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/bloc/treasure_hunt_state.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/pages/qr_scanner_page.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/pages/scan_history_page.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/point_type_presentation.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/widgets/treasure_hunt_checklist_sheet.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/widgets/treasure_hunt_point_details_sheet.dart';
import 'package:sggw_days/features/treasure_hunt/presentation/widgets/treasure_hunt_widgets.dart';
import 'package:sggw_days/features/wiki/presentation/bloc/wiki_bloc.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class TreasureHuntPage extends StatefulWidget {
  const TreasureHuntPage({super.key});

  @override
  State<TreasureHuntPage> createState() => _TreasureHuntPageState();
}

class _TreasureHuntPageState extends State<TreasureHuntPage> {
  final MapController _mapController = MapController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  String? _selectedPointId;
  double _currentZoom = 16;
  bool _showCelebrationFlash = false;
  bool _completionCelebrated = false;
  // SGGW coordinates
  static const LatLng sggwCenter = LatLng(52.1598, 21.0463);

  @override
  void initState() {
    super.initState();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mapShadowColor = colorScheme.shadow.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.32 : 0.18,
    );
    final mapOutlineColor = colorScheme.outlineVariant.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.72 : 0.6,
    );
    final markerLabelBackgroundColor = colorScheme.surface.withValues(
      alpha: 0.96,
    );
    final markerDistanceBackgroundColor = colorScheme.surfaceContainerHighest
        .withValues(alpha: 0.96);

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
            onPressed: () => _openScanHistoryPage(context),
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
          final allPointsFound =
              state.points.isNotEmpty &&
              state.points.every(
                (point) => state.foundPointIds.contains(point.id),
              ) &&
              state.status == TreasureHuntStatus.success;
          if (!allPointsFound) {
            _completionCelebrated = false;
          }

          // Show confetti + congratulation popup when a treasure point is scanned
          if (state.lastScannedPointId != null) {
            final scannedPoint = state.points
                .where((p) => p.id == state.lastScannedPointId)
                .firstOrNull;
            if (scannedPoint != null &&
                scannedPoint.type == PointType.treasurePoint) {
              unawaited(_playTreasureCelebration(context));
              _showPointCollectedDialog(
                context,
                scannedPoint,
                allPointsFound: allPointsFound,
              );
              if (allPointsFound) {
                _completionCelebrated = true;
              }
              return;
            }
          }
          // Check if all points found
          if (allPointsFound && !_completionCelebrated) {
            _completionCelebrated = true;
            _showCelebration(context);
          }
        },
        builder: (context, state) {
          if (state.status == TreasureHuntStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final skipTreasureHunt = context.select<SettingsCubit, bool>(
            (c) => c.state.skipTreasureHunt,
          );
          final hasScanned = state.foundPointIds.isNotEmpty;
          final visiblePointIds = state.visiblePointIds(
            skipTreasureHunt: skipTreasureHunt,
          );
          final showBanner = !hasScanned && !skipTreasureHunt;
          final disableAnimations = MediaQuery.disableAnimationsOf(context);
          final markerAnimationDuration = disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 180);
          final visiblePoints = state.points
              .where((point) => visiblePointIds.contains(point.id))
              .toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: sggwCenter,
                  initialZoom: 16.0,
                  minZoom: 14.0,
                  maxZoom: 19.0,
                  onPositionChanged: (camera, hasGesture) {
                    if ((_currentZoom - camera.zoom).abs() < 0.15) return;
                    setState(() => _currentZoom = camera.zoom);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sggw.days',
                  ),
                  MarkerLayer(
                    rotate: true,
                    markers: [
                      ..._buildClusteredMarkers(
                        context: context,
                        points: visiblePoints,
                        foundPointIds: state.foundPointIds.toSet(),
                        trackedPointId: state.trackedPointId,
                        markerAnimationDuration: markerAnimationDuration,
                        markerLabelBackgroundColor: markerLabelBackgroundColor,
                        markerDistanceBackgroundColor:
                            markerDistanceBackgroundColor,
                        mapOutlineColor: mapOutlineColor,
                        mapShadowColor: mapShadowColor,
                      ),
                      if (_currentPosition != null)
                        Marker(
                          point: _currentPosition!,
                          width: 40,
                          height: 40,
                          child: const UserLocationMarker(),
                        ),
                    ],
                  ),
                ],
              ),
              IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _showCelebrationFlash ? 1 : 0,
                  duration: disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: ColoredBox(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  ),
                ),
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
                  emissionFrequency: 0.04,
                  numberOfParticles: 30,
                  gravity: 0.1,
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.tertiary,
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                    colorScheme.surface,
                  ],
                ),
              ),
              if (showBanner)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.1),
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
                          const SizedBox(width: 8),
                          Tooltip(
                            message: AppLocalizations.of(
                              context,
                            )!.continueWithoutTreasureHunt,
                            child: IconButton(
                              icon: Icon(
                                Icons.skip_next_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                              onPressed: () =>
                                  _confirmSkipTreasureHunt(context),
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

  List<Marker> _buildClusteredMarkers({
    required BuildContext context,
    required List<TreasurePoint> points,
    required Set<String> foundPointIds,
    required String? trackedPointId,
    required Duration markerAnimationDuration,
    required Color markerLabelBackgroundColor,
    required Color markerDistanceBackgroundColor,
    required Color mapOutlineColor,
    required Color mapShadowColor,
  }) {
    final clusters = clusterTreasurePoints(
      points,
      radiusMeters: _clusterRadiusForZoom(_currentZoom),
    );

    return clusters.map((cluster) {
      if (cluster.isCluster) {
        return _buildClusterMarker(
          context: context,
          cluster: cluster,
          foundPointIds: foundPointIds,
          mapOutlineColor: mapOutlineColor,
          mapShadowColor: mapShadowColor,
        );
      }

      return _buildPointMarker(
        context: context,
        point: cluster.points.single,
        foundPointIds: foundPointIds,
        trackedPointId: trackedPointId,
        markerAnimationDuration: markerAnimationDuration,
        markerLabelBackgroundColor: markerLabelBackgroundColor,
        markerDistanceBackgroundColor: markerDistanceBackgroundColor,
        mapOutlineColor: mapOutlineColor,
        mapShadowColor: mapShadowColor,
      );
    }).toList();
  }

  Marker _buildClusterMarker({
    required BuildContext context,
    required TreasurePointCluster cluster,
    required Set<String> foundPointIds,
    required Color mapOutlineColor,
    required Color mapShadowColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasUnfoundTreasure = cluster.points.any(
      (point) =>
          point.type == PointType.treasurePoint &&
          !foundPointIds.contains(point.id),
    );
    final clusterColor = hasUnfoundTreasure
        ? colorScheme.primary
        : colorScheme.secondary;

    return Marker(
      point: cluster.center,
      width: 56,
      height: 56,
      child: Semantics(
        button: true,
        label:
            '${cluster.points.length} ${AppLocalizations.of(context)!.points}',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              _showPointCluster(context, cluster.points, foundPointIds),
          child: Center(
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: clusterColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: mapShadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.layers_rounded, color: clusterColor, size: 20),
                  Positioned(
                    right: 1,
                    top: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: mapOutlineColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 0,
                        ),
                        child: Text(
                          '${cluster.points.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Marker _buildPointMarker({
    required BuildContext context,
    required TreasurePoint point,
    required Set<String> foundPointIds,
    required String? trackedPointId,
    required Duration markerAnimationDuration,
    required Color markerLabelBackgroundColor,
    required Color markerDistanceBackgroundColor,
    required Color mapOutlineColor,
    required Color mapShadowColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFound = foundPointIds.contains(point.id);
    final typeColor = colorForPointType(point.type, colorScheme);
    final isTracked = trackedPointId == point.id;
    final isSelected = _selectedPointId == point.id;
    final showMarkerLabel = isTracked || isSelected;
    final showDistance = isTracked && _currentPosition != null;

    return Marker(
      point: LatLng(point.latitude, point.longitude),
      width: 116,
      height: 96,
      child: Semantics(
        button: true,
        label: point.name,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleMarkerTap(context, point, isFound),
          child: AnimatedScale(
            duration: markerAnimationDuration,
            curve: Curves.easeOutBack,
            scale: isTracked ? 1.06 : (isSelected ? 1.03 : 1.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 34,
                  child: AnimatedOpacity(
                    duration: markerAnimationDuration,
                    opacity: showMarkerLabel ? 1 : 0,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 104),
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: markerLabelBackgroundColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: mapOutlineColor),
                        boxShadow: [
                          BoxShadow(
                            color: mapShadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        point.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: typeColor,
                      width: isSelected ? 2.4 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mapShadowColor,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                      if (isTracked || isSelected)
                        BoxShadow(
                          color: typeColor.withValues(alpha: 0.28),
                          blurRadius: 14,
                          spreadRadius: 3,
                        ),
                    ],
                  ),
                  child: Icon(
                    isFound ? Icons.check_circle : iconForPointType(point.type),
                    color: isFound
                        ? typeColor.withValues(alpha: 0.82)
                        : typeColor,
                    size: isTracked || isSelected ? 24 : 21,
                  ),
                ),
                SizedBox(
                  height: 22,
                  child: showDistance
                      ? Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: markerDistanceBackgroundColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: mapOutlineColor),
                            boxShadow: [
                              BoxShadow(
                                color: mapShadowColor,
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
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
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPointCluster(
    BuildContext context,
    List<TreasurePoint> points,
    Set<String> foundPointIds,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text(l10n.groupedPoints, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ...points.map((point) {
            final isFound = foundPointIds.contains(point.id);
            final color = colorForPointType(point.type, theme.colorScheme);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  isFound ? Icons.check_circle : iconForPointType(point.type),
                  color: color,
                ),
                title: Text(point.name),
                subtitle: Text(labelForPointType(point.type, l10n)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (!mounted) return;
                  unawaited(_handleMarkerTap(context, point, isFound));
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  double _clusterRadiusForZoom(double zoom) {
    if (zoom >= 18.25) return 7;
    if (zoom >= 17.25) return 11;
    if (zoom >= 16.25) return 18;
    if (zoom >= 15.25) return 30;
    return 48;
  }

  void _showChecklist(BuildContext context) {
    final huntState = context.read<TreasureHuntBloc>().state;
    final skipTreasureHunt = context
        .read<SettingsCubit>()
        .state
        .skipTreasureHunt;

    final treasurePoints = huntState.sortedTreasurePoints;
    final foundIds = huntState.foundPointIds.toSet();
    final unlocked = huntState.unlockedPointIds;
    final visiblePointIds = huntState.visiblePointIds(
      skipTreasureHunt: skipTreasureHunt,
    );
    final visiblePois = huntState.points
        .where((point) => point.type == PointType.pointOfInterest)
        .where((point) => visiblePointIds.contains(point.id))
        .toList();

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
      _trackPointAndZoom(context, point, hasScanned: foundIds.isNotEmpty);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => TreasureHuntChecklistSheet(
        treasurePoints: treasurePoints,
        visiblePointsOfInterest: visiblePois,
        foundPointIds: foundIds,
        nextTreasure: nextTreasure,
        treasureRemaining: treasureRemaining,
        onPointSelected: trackAndClose,
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

  void _showPointCollectedDialog(
    BuildContext context,
    TreasurePoint point, {
    required bool allPointsFound,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          allPointsFound ? Icons.auto_awesome : Icons.emoji_events,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          allPointsFound ? l10n.congratulations : l10n.pointCollected,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.pointCollectedDesc(point.name),
              textAlign: TextAlign.center,
            ),
            if (allPointsFound) ...[
              const SizedBox(height: 12),
              Text(
                l10n.allPointsFound,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.treasureHuntCompleteEasterEgg,
                textAlign: TextAlign.center,
              ),
            ],
          ],
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
            child: Text(allPointsFound ? l10n.ok : l10n.continueScan),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMarkerTap(
    BuildContext context,
    TreasurePoint point,
    bool isFound,
  ) async {
    await HapticFeedback.selectionClick();
    if (!mounted || !context.mounted) return;
    setState(() {
      _selectedPointId = point.id;
    });
    await _showPointDetails(context, point, isFound);
  }

  Future<void> _playTreasureCelebration(BuildContext context) async {
    await HapticFeedback.heavyImpact();
    unawaited(HapticFeedback.selectionClick());
    if (!mounted || !context.mounted) {
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      return;
    }

    _confettiController.play();
    unawaited(_flashCelebration());
  }

  Future<void> _flashCelebration() async {
    if (!mounted) return;
    setState(() {
      _showCelebrationFlash = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 240));
    if (!mounted) return;
    setState(() {
      _showCelebrationFlash = false;
    });
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

  void _trackPointAndZoom(
    BuildContext context,
    TreasurePoint point, {
    required bool hasScanned,
  }) {
    HapticFeedback.lightImpact();
    if (mounted) {
      setState(() {
        _selectedPointId = point.id;
      });
    }
    context.read<TreasureHuntBloc>().add(TrackPoint(point.id));
    _zoomToFitTracked(context, point, hasScanned: hasScanned);
  }

  void _openScanHistoryPage(BuildContext context) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanHistoryPage()),
    );
  }

  Future<void> _showPointDetails(
    BuildContext context,
    TreasurePoint point,
    bool isFound,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final huntState = context.read<TreasureHuntBloc>().state;
    final skipTreasureHunt = context
        .read<SettingsCubit>()
        .state
        .skipTreasureHunt;
    final isVisible = huntState
        .visiblePointIds(skipTreasureHunt: skipTreasureHunt)
        .contains(point.id);
    final isUnlocked = huntState.unlockedPointIds.contains(point.id);
    final canScan =
        point.type == PointType.treasurePoint && isUnlocked && !isFound;
    final hasScanned = huntState.foundPointIds.isNotEmpty;
    String? distanceText;
    double? distanceMeters;
    if (_currentPosition != null) {
      distanceMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        point.latitude,
        point.longitude,
      );
      distanceText = _formatDistance(distanceMeters);
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

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        void closeThen(VoidCallback action) {
          Navigator.pop(sheetContext);
          unawaited(
            Future<void>.delayed(Duration.zero, () {
              if (!mounted) return;
              action();
            }),
          );
        }

        return TreasureHuntPointDetailsSheet(
          point: point,
          isFound: isFound,
          canScan: canScan,
          distanceText: distanceText,
          distanceMeters: distanceMeters,
          relatedWikis: relatedWikis,
          relatedEvents: relatedEvents,
          onTrack: () => closeThen(
            () => _trackPointAndZoom(context, point, hasScanned: hasScanned),
          ),
          onOpenWiki: () => closeThen(() => GoRouter.of(context).go('/wiki')),
          onOpenTimetable: () =>
              closeThen(() => GoRouter.of(context).go('/timetable')),
          onSecondaryAction: !isVisible
              ? null
              : () => closeThen(() {
                  if (canScan) {
                    _openQRScanner(context);
                    return;
                  }
                  if (isFound) {
                    _openScanHistoryPage(context);
                    return;
                  }
                  _showChecklist(context);
                }),
          secondaryActionIcon: canScan
              ? Icons.qr_code_scanner
              : (isFound ? Icons.history : Icons.checklist),
          secondaryActionLabel: canScan
              ? l10n.scanQr
              : (isFound ? l10n.scanHistory : l10n.checklist),
        );
      },
    );
  }

  void _openQRScanner(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // Ensure camera permission (re-ask instead of failing)
    final cameraOk = await _ensurePermission(
      context,
      Permission.camera,
      l10n.permissionDeniedCameraBody,
    );
    if (!context.mounted || !cameraOk) return;

    // Ensure location permission (re-ask instead of failing)
    final locationOk = await _ensureLocationPermission(context);
    if (!context.mounted || !locationOk) return;

    try {
      final position = await Geolocator.getCurrentPosition();

      if (!context.mounted) return;

      final scannedCode = await Navigator.of(context, rootNavigator: true)
          .push<String>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => QrScannerPage(
                currentPosition: position,
                treasurePoints: context.read<TreasureHuntBloc>().state.points,
                unlockedPointIds: context
                    .read<TreasureHuntBloc>()
                    .state
                    .unlockedPointIds,
              ),
            ),
          );
      if (!context.mounted || scannedCode == null) return;
      context.read<TreasureHuntBloc>().add(ScanQRCode(scannedCode));
    } catch (_) {
      if (!context.mounted) return;
      // Re-ask for location instead of showing an error.
      await _ensureLocationPermission(context);
    }
  }

  Future<bool> _ensurePermission(
    BuildContext context,
    Permission permission,
    String explanation,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    var status = await permission.status;
    if (status.isGranted) return true;

    // First attempt: request directly.
    status = await permission.request();
    if (status.isGranted) return true;

    // If still not granted, keep re-asking via a dialog loop until the user
    // explicitly cancels or grants it.
    while (!status.isGranted) {
      if (!context.mounted) return false;
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.lock_outline, size: 48),
          title: Text(l10n.permissionDeniedTitle),
          content: Text(explanation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: Text(l10n.cancel),
            ),
            if (status.isPermanentlyDenied)
              FilledButton.tonal(
                onPressed: () => Navigator.pop(ctx, 'settings'),
                child: Text(l10n.permissionDeniedOpenSettings),
              ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'retry'),
              child: Text(l10n.permissionDeniedRetry),
            ),
          ],
        ),
      );
      if (action == 'settings') {
        await openAppSettings();
        status = await permission.status;
      } else if (action == 'retry') {
        status = await permission.request();
      } else {
        return false;
      }
    }
    return status.isGranted;
  }

  Future<bool> _ensureLocationPermission(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always) {
      return true;
    }
    perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always) {
      return true;
    }
    while (perm != LocationPermission.whileInUse &&
        perm != LocationPermission.always) {
      if (!context.mounted) return false;
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.lock_outline, size: 48),
          title: Text(l10n.permissionDeniedTitle),
          content: Text(l10n.permissionDeniedLocationBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: Text(l10n.cancel),
            ),
            if (perm == LocationPermission.deniedForever)
              FilledButton.tonal(
                onPressed: () => Navigator.pop(ctx, 'settings'),
                child: Text(l10n.permissionDeniedOpenSettings),
              ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'retry'),
              child: Text(l10n.permissionDeniedRetry),
            ),
          ],
        ),
      );
      if (action == 'settings') {
        await Geolocator.openAppSettings();
        perm = await Geolocator.checkPermission();
      } else if (action == 'retry') {
        perm = await Geolocator.requestPermission();
      } else {
        return false;
      }
    }
    return perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always;
  }

  Future<void> _confirmSkipTreasureHunt(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.skip_next_outlined, size: 48),
        title: Text(l10n.skipTreasureHuntDialogTitle),
        content: Text(l10n.skipTreasureHuntDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.continueWithoutTreasureHunt),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<SettingsCubit>().setSkipTreasureHunt(true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.skipTreasureHuntEnabledSnack)));
  }
}
