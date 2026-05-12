import 'package:flutter/material.dart';
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
          Text(
            '${l10n.rewardClaimDeviceId}: $shortDeviceId',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
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
