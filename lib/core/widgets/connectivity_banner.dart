import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/core/connectivity/connectivity_cubit.dart';
import 'package:sggw_days/l10n/app_localizations.dart';
import 'package:sggw_days/main.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _offlineBannerDismissed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, status) {
        final showOfflineBanner =
            !isFirebaseAvailable &&
            !_offlineBannerDismissed &&
            status != ConnectivityStatus.offline;

        return Column(
          children: [
            if (status == ConnectivityStatus.offline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: colorScheme.error,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      color: colorScheme.onError,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.noConnection,
                      style: TextStyle(
                        color: colorScheme.onError,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (showOfflineBanner)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
                color: colorScheme.tertiaryContainer,
                child: Row(
                  children: [
                    Icon(
                      Icons.offline_bolt_outlined,
                      color: colorScheme.onTertiaryContainer,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.offlineMode,
                        style: TextStyle(
                          color: colorScheme.onTertiaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _offlineBannerDismissed = true;
                      }),
                      child: Icon(
                        Icons.close,
                        color: colorScheme.onTertiaryContainer,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: widget.child),
          ],
        );
      },
    );
  }
}
