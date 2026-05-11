import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sggw_days/core/widgets/qr_code_widget.dart';
import 'package:sggw_days/features/rewards/data/models/reward_claim_payload.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class RewardClaimSheet extends StatelessWidget {
  final RewardClaimPayload payload;

  const RewardClaimSheet({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final shortDeviceId = payload.deviceId.length > 12
        ? payload.deviceId.substring(payload.deviceId.length - 12)
        : payload.deviceId;

    return FractionallySizedBox(
      heightFactor: 0.86,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewPaddingOf(context).bottom + 20,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.redeem_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rewardClaimTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.rewardClaimBody),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: QrCodeWidget(data: payload.toQrData(), size: 220),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(
                    label: l10n.rewardClaimDeviceId,
                    value: shortDeviceId,
                  ),
                  _SummaryRow(
                    label: l10n.rewardClaimPayloadHash,
                    value: payload.payloadHash,
                  ),
                  _SummaryRow(
                    label: l10n.rewardClaimTreasureScans,
                    value: '${payload.treasureScans.length}',
                  ),
                  _SummaryRow(
                    label: l10n.rewardClaimEventCheckIns,
                    value: '${payload.eventCheckIns.length}',
                  ),
                  if (payload.completedAt != null)
                    _SummaryRow(
                      label: l10n.rewardClaimCompletedAt,
                      value: DateFormat.yMMMd().add_Hm().format(
                        payload.completedAt!,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
