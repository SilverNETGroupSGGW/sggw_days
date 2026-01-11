import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;
  final Box settingsBox;

  const OnboardingPage({
    super.key,
    required this.onComplete,
    required this.settingsBox,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final locationStatus = await Permission.location.status;
    setState(() {
      _permissionsGranted = cameraStatus.isGranted && locationStatus.isGranted;
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.location.request();
    await _checkPermissions();
  }

  Future<void> _completeOnboarding() async {
    await widget.settingsBox.put('onboarding_completed', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: l10n.welcome,
          body: l10n.onboardingWelcomeDesc,
          image: Center(
            child: Icon(Icons.map, size: 120, color: colorScheme.primary),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        PageViewModel(
          title: l10n.onboardingTreasureHuntTitle,
          body: l10n.onboardingTreasureHuntDesc,
          image: Center(
            child: Icon(
              Icons.qr_code_scanner,
              size: 120,
              color: colorScheme.primary,
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        PageViewModel(
          title: l10n.onboardingWikiTitle,
          body: l10n.onboardingWikiDesc,
          image: Center(
            child: Icon(Icons.info, size: 120, color: colorScheme.primary),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        PageViewModel(
          title: l10n.onboardingTimetableTitle,
          body: l10n.onboardingTimetableDesc,
          image: Center(
            child: Icon(
              Icons.calendar_today,
              size: 120,
              color: colorScheme.primary,
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        PageViewModel(
          title: l10n.onboardingPermissionsTitle,
          body: l10n.onboardingPermissionsDesc,
          image: Center(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.location_on, size: 100, color: colorScheme.primary),
                Icon(Icons.camera_alt, size: 100, color: colorScheme.primary),
              ],
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            footerFlex: 0,
          ),
          footer: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _permissionsGranted ? null : _requestPermissions,
                icon: Icon(
                  _permissionsGranted
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
                label: Text(
                  _permissionsGranted
                      ? l10n.permissionsGranted
                      : l10n.grantPermissions,
                ),
              ),
            ),
          ),
        ),
      ],
      onDone: _completeOnboarding,
      onSkip: _completeOnboarding,
      showSkipButton: true,
      skip: Text(l10n.skip),
      next: Text(l10n.next),
      done: Text(l10n.getStarted),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: colorScheme.primary,
        color: colorScheme.onSurface.withValues(alpha: 0.3),
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
