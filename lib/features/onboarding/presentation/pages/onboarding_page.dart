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
  final GlobalKey<IntroductionScreenState> _introKey =
      GlobalKey<IntroductionScreenState>();
  bool _permissionsGranted = false;
  bool _requestingPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final locationStatus = await Permission.location.status;
    if (!mounted) return;
    setState(() {
      _permissionsGranted = cameraStatus.isGranted && locationStatus.isGranted;
    });
  }

  Future<void> _requestPermissions() async {
    if (_requestingPermissions) return;
    setState(() => _requestingPermissions = true);
    try {
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }
      var locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        locationStatus = await Permission.location.request();
      }
      if (!mounted) return;
      final granted = cameraStatus.isGranted && locationStatus.isGranted;
      setState(() {
        _permissionsGranted = granted;
      });
    } finally {
      if (mounted) {
        setState(() => _requestingPermissions = false);
      }
    }
  }

  Future<void> _completeOnboarding() async {
    await widget.settingsBox.put('onboarding_completed', true);
    if (!mounted) return;
    widget.onComplete();
  }

  Future<void> _confirmSkipTreasureHunt() async {
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
    if (confirmed != true || !mounted) return;
    await widget.settingsBox.put('non_game_mode', true);
    if (!mounted) return;
    await _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox.expand(
      child: IntroductionScreen(
        key: _introKey,
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
                  Icon(
                    Icons.location_on,
                    size: 100,
                    color: colorScheme.primary,
                  ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _permissionsGranted || _requestingPermissions
                          ? null
                          : _requestPermissions,
                      icon: _requestingPermissions
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _permissionsGranted
                                  ? Icons.check_circle
                                  : Icons.shield_outlined,
                            ),
                      label: Text(
                        _permissionsGranted
                            ? l10n.permissionsGranted
                            : l10n.grantPermissions,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _confirmSkipTreasureHunt,
                    icon: const Icon(Icons.skip_next_outlined),
                    label: Text(l10n.continueWithoutTreasureHunt),
                  ),
                ],
              ),
            ),
          ),
        ],
        onDone: _completeOnboarding,
        showSkipButton: false,
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
      ),
    );
  }
}
