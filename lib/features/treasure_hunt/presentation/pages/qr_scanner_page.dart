import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_scan_code.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class QrScannerPage extends StatefulWidget {
  final List<TreasurePoint> treasurePoints;
  final Set<String> unlockedPointIds;

  const QrScannerPage({
    super.key,
    required this.treasurePoints,
    required this.unlockedPointIds,
  });

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  static const Duration _scanErrorCooldown = Duration(seconds: 3);

  late final MobileScannerController _controller;
  Position? _currentPosition;
  Object? _locationError;
  bool _allowPop = false;
  bool _hasHandledScan = false;
  bool _isClosing = false;
  DateTime? _scanErrorCooldownUntil;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    unawaited(_loadCurrentPosition());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TreasurePoint? _findPoint(String code) {
    final pointId = tryExtractTreasurePointId(code);
    if (pointId != null) {
      return widget.treasurePoints.where((p) => p.id == pointId).firstOrNull;
    }
    return widget.treasurePoints.where((p) => p.qrCode == code).firstOrNull;
  }

  Future<void> _loadCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _locationError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _locationError = error;
      });
    }
  }

  bool _isNearTreasurePoint(TreasurePoint point) {
    if (kDebugMode) return true;

    final currentPosition = _currentPosition;
    if (currentPosition == null) return false;

    const maxDistance = 50.0;
    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      point.latitude,
      point.longitude,
    );
    return distance <= maxDistance;
  }

  Future<void> _closeScanner([String? scannedCode]) async {
    if (!mounted || _isClosing) return;
    _isClosing = true;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await _controller.stop();
    if (!mounted) return;
    Navigator.of(context).pop(scannedCode);
  }

  void _completeScan(String code) {
    if (_hasHandledScan) return;
    _hasHandledScan = true;
    unawaited(_closeScanner(code));
  }

  bool get _isInScanErrorCooldown {
    final cooldownUntil = _scanErrorCooldownUntil;
    return cooldownUntil != null && DateTime.now().isBefore(cooldownUntil);
  }

  void _showScanError(BuildContext context, String message) {
    _scanErrorCooldownUntil = DateTime.now().add(_scanErrorCooldown);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: _scanErrorCooldown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope<void>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          unawaited(_controller.stop());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.scanQr),
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(Icons.close),
            onPressed: () => unawaited(_closeScanner()),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_hasHandledScan ||
                    _isClosing ||
                    _isInScanErrorCooldown ||
                    _currentPosition == null ||
                    _locationError != null) {
                  return;
                }
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final rawValue = barcode.rawValue;
                  if (rawValue == null) {
                    continue;
                  }

                  final point = _findPoint(rawValue);
                  if (point == null) {
                    _showScanError(context, l10n.invalidQrCode);
                  } else if (!widget.unlockedPointIds.contains(point.id)) {
                    _showScanError(context, l10n.pointLocked);
                  } else if (_isNearTreasurePoint(point)) {
                    _completeScan(rawValue);
                  } else {
                    _showScanError(context, l10n.mustBeCloser);
                  }
                  break;
                }
              },
            ),
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                final isCameraReady =
                    state.isInitialized &&
                    state.isRunning &&
                    state.error == null;
                if (isCameraReady && _currentPosition != null) {
                  return const SizedBox.shrink();
                }

                if (_locationError != null) {
                  return Container(
                    color: Colors.black.withValues(alpha: 0.85),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_off,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.permissionDeniedLocationBody,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _locationError = null;
                            });
                            unawaited(_loadCurrentPosition());
                          },
                          child: Text(l10n.permissionDeniedRetry),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  color: Colors.black.withValues(alpha: 0.85),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        l10n.cameraLoading,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
