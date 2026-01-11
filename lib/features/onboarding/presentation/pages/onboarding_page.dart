import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sggw_days/l10n/app_localizations.dart';

class OnboardingPage extends StatelessWidget {
  final VoidCallback onComplete;
  final Box settingsBox;

  const OnboardingPage({
    super.key,
    required this.onComplete,
    required this.settingsBox,
  });

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.location.request();
  }

  Future<void> _completeOnboarding() async {
    await settingsBox.put('onboarding_completed', true);
    onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: l10n.welcome,
          body: l10n.onboardingTitle1,
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
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        PageViewModel(
          title: l10n.onboardingTitle1,
          body: l10n.onboardingDesc1,
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
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        PageViewModel(
          title: l10n.onboardingTitle2,
          body: l10n.onboardingDesc2,
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
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        PageViewModel(
          title: l10n.onboardingTitle3,
          body: l10n.onboardingDesc3,
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
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        PageViewModel(
          title: l10n.onboardingTitle4,
          body: l10n.onboardingDesc4,
          image: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 60, color: colorScheme.primary),
                const SizedBox(height: 16),
                Icon(Icons.camera_alt, size: 60, color: colorScheme.primary),
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
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          footer: FilledButton.icon(
            onPressed: _requestPermissions,
            icon: const Icon(Icons.check),
            label: Text(l10n.getStarted),
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
        color: colorScheme.onSurface.withOpacity(0.3),
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
