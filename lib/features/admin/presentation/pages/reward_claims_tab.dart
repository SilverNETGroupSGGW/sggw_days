import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sggw_days/features/admin/data/repositories/admin_repository.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_state.dart';
import 'package:sggw_days/features/rewards/data/models/reward_claim_payload.dart';
import 'package:sggw_days/features/treasure_hunt/data/models/treasure_point.dart';

class RewardClaimsTab extends StatefulWidget {
  const RewardClaimsTab({super.key});

  @override
  State<RewardClaimsTab> createState() => _RewardClaimsTabState();
}

class _RewardClaimsTabState extends State<RewardClaimsTab> {
  final TextEditingController _payloadController = TextEditingController();
  RewardClaimPayload? _payload;
  Map<String, dynamic>? _existingClaim;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _payloadController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final rawData = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const _RewardQrScannerPage(),
      ),
    );
    if (!mounted || rawData == null) return;
    _payloadController.text = rawData;
    await _parsePayload(rawData);
  }

  Future<void> _parsePayload(String rawData) async {
    final payload = RewardClaimPayload.tryParseQrData(rawData);
    if (payload == null) {
      setState(() {
        _payload = null;
        _existingClaim = null;
        _error = 'This is not a valid reward claim QR code.';
      });
      return;
    }

    setState(() {
      _payload = payload;
      _existingClaim = null;
      _error = null;
      _isLoading = true;
    });

    try {
      final existing = await context.read<AdminRepository>().fetchRewardClaim(
        payload.deviceId,
      );
      if (!mounted) return;
      setState(() {
        _existingClaim = existing;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load reward status: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _markReceived() async {
    final payload = _payload;
    if (payload == null) return;
    final repository = context.read<AdminRepository>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    try {
      await repository.markRewardReceived(payload);
      final existing = await repository.fetchRewardClaim(payload.deviceId);
      if (!mounted) return;
      setState(() {
        _existingClaim = existing;
        _isLoading = false;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Reward marked as received.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        final payload = _payload;
        final validation = payload == null
            ? null
            : _validatePayload(payload, state);
        final canMarkReceived =
            payload != null &&
            validation!.isValid &&
            _existingClaim == null &&
            !_isLoading;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _scanQr,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan reward QR'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _parsePayload(_payloadController.text),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Verify pasted code'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _payloadController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Reward QR payload',
                border: OutlineInputBorder(),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!),
                ),
              ),
            ],
            if (payload != null && validation != null) ...[
              const SizedBox(height: 16),
              _RewardSummaryCard(
                payload: payload,
                validation: validation,
                existingClaim: _existingClaim,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: canMarkReceived ? _markReceived : null,
                icon: const Icon(Icons.redeem_rounded),
                label: Text(
                  _existingClaim == null
                      ? 'Mark reward received'
                      : 'Reward already received',
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  _RewardPayloadValidation _validatePayload(
    RewardClaimPayload payload,
    AdminState state,
  ) {
    final requiredTreasureIds = state.treasurePoints
        .where((point) => point.type == PointType.treasurePoint)
        .map((point) => point.id)
        .toSet();
    final payloadTreasureIds = payload.treasureScans
        .map((record) => record.id)
        .toSet();
    final missingTreasureIds = requiredTreasureIds.difference(
      payloadTreasureIds,
    );
    final validEventIds = state.timetableEvents
        .map((event) => event.id)
        .toSet();
    final knownEventCheckIns = payload.eventCheckIns
        .where((record) => validEventIds.contains(record.id))
        .length;

    return _RewardPayloadValidation(
      missingTreasureIds: missingTreasureIds.toList()..sort(),
      hasKnownEventCheckIn: knownEventCheckIns > 0,
    );
  }
}

class _RewardPayloadValidation {
  final List<String> missingTreasureIds;
  final bool hasKnownEventCheckIn;

  const _RewardPayloadValidation({
    required this.missingTreasureIds,
    required this.hasKnownEventCheckIn,
  });

  bool get isValid => missingTreasureIds.isEmpty && hasKnownEventCheckIn;
}

class _RewardSummaryCard extends StatelessWidget {
  final RewardClaimPayload payload;
  final _RewardPayloadValidation validation;
  final Map<String, dynamic>? existingClaim;

  const _RewardSummaryCard({
    required this.payload,
    required this.validation,
    required this.existingClaim,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final existingClaim = this.existingClaim;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  existingClaim == null
                      ? Icons.verified_outlined
                      : Icons.history_toggle_off,
                  color: existingClaim == null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  existingClaim == null
                      ? 'Reward not received yet'
                      : 'Reward already received',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AdminSummaryRow(label: 'Device ID', value: payload.deviceId),
            _AdminSummaryRow(
              label: 'Verification code',
              value: payload.payloadHash,
            ),
            _AdminSummaryRow(
              label: 'Treasure scans',
              value: '${payload.treasureScans.length}',
            ),
            _AdminSummaryRow(
              label: 'Event check-ins',
              value: '${payload.eventCheckIns.length}',
            ),
            if (payload.completedAt != null)
              _AdminSummaryRow(
                label: 'Completed at',
                value: DateFormat.yMMMd().add_Hm().format(payload.completedAt!),
              ),
            if (existingClaim != null) ...[
              const Divider(height: 24),
              _AdminSummaryRow(
                label: 'Received at',
                value: _formatClaimDate(existingClaim['receivedAt']),
              ),
              _AdminSummaryRow(
                label: 'Received by',
                value:
                    '${existingClaim['receivedByEmail'] ?? existingClaim['receivedBy'] ?? 'Unknown'}',
              ),
            ],
            if (!validation.isValid) ...[
              const Divider(height: 24),
              Text(
                'Not eligible yet',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              if (validation.missingTreasureIds.isNotEmpty)
                Text(
                  'Missing treasure points: ${validation.missingTreasureIds.join(', ')}',
                ),
              if (!validation.hasKnownEventCheckIn)
                const Text('No known timetable event check-in found.'),
            ],
          ],
        ),
      ),
    );
  }

  String _formatClaimDate(Object? value) {
    if (value is Timestamp) {
      return DateFormat.yMMMd().add_Hm().format(value.toDate());
    }
    return 'Unknown';
  }
}

class _AdminSummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _AdminSummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardQrScannerPage extends StatefulWidget {
  const _RewardQrScannerPage();

  @override
  State<_RewardQrScannerPage> createState() => _RewardQrScannerPageState();
}

class _RewardQrScannerPageState extends State<_RewardQrScannerPage> {
  late final MobileScannerController _controller;
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

  Future<void> _completeScan(String code) async {
    if (!mounted || _isClosing) return;
    _isClosing = true;
    await _controller.stop();
    if (!mounted) return;
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan reward QR')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_isClosing) return;
          final rawValue = capture.barcodes.firstOrNull?.rawValue;
          if (rawValue == null) return;
          unawaited(_completeScan(rawValue));
        },
      ),
    );
  }
}
