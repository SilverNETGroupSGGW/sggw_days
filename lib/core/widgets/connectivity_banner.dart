import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sggw_days/core/connectivity/connectivity_cubit.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, status) {
        return Column(
          children: [
            if (status == ConnectivityStatus.offline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: Theme.of(context).colorScheme.error,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      color: Theme.of(context).colorScheme.onError,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.noConnection,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
