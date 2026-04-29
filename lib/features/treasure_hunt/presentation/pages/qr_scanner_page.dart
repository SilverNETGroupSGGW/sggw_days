import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_scan_code.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class QrScannerPage extends StatefulWidget {
  final Position currentPosition;
  final List<TreasurePoint> treasurePoints;
  final Set<String> unlockedPointIds;

  const QrScannerPage({
    super.key,
    required this.currentPosition,
    required this.treasurePoints,
    required this.unlockedPointIds,
  });

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  late final MobileScannerController _controller;
  bool _allowPop = false;
  bool _hasHandledScan = false;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
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

  bool _isNearTreasurePoint(TreasurePoint point) {
    if (kDebugMode) return true;

    const maxDistance = 50.0;
    final distance = Geolocator.distanceBetween(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
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
                if (_hasHandledScan || _isClosing) return;
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final rawValue = barcode.rawValue;
                  if (rawValue == null) {
                    continue;
                  }

                  final point = _findPoint(rawValue);
                  if (point == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.invalidQrCode),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  } else if (!widget.unlockedPointIds.contains(point.id)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.pointLocked),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  } else if (_isNearTreasurePoint(point)) {
                    _completeScan(rawValue);
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
              },
            ),
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                final isReady =
                    state.isInitialized &&
                    state.isRunning &&
                    state.error == null;
                if (isReady) {
                  return const SizedBox.shrink();
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
