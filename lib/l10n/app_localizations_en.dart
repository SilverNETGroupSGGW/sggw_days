// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SGGW Days';

  @override
  String get treasureHunt => 'Treasure Hunt';

  @override
  String get wiki => 'Wiki';

  @override
  String get timetable => 'Timetable';

  @override
  String get notifications => 'Notifications';

  @override
  String get map => 'Map';

  @override
  String get scanQr => 'Scan QR';

  @override
  String get points => 'Points';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String score(int value) {
    return 'Score: $value';
  }

  @override
  String get pointFound => 'Point found!';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get noConnection => 'No internet connection';

  @override
  String get colorScheme => 'Color scheme';

  @override
  String get sggwColors => 'SGGW colors';

  @override
  String get dynamicColors => 'Dynamic colors';

  @override
  String get welcome => 'Welcome to SGGW Days!';

  @override
  String get onboardingWelcomeDesc =>
      'Discover SGGW campus, learn about the university, and enjoy the SGGW Days events!';

  @override
  String get onboardingTreasureHuntTitle => 'Treasure Hunt';

  @override
  String get onboardingTreasureHuntDesc =>
      'Find hidden points on campus, scan QR codes and earn points. You must be close to a point to scan its code.';

  @override
  String get onboardingWikiTitle => 'SGGW Knowledge';

  @override
  String get onboardingWikiDesc =>
      'Learn more about the university\'s history, lecturers and interesting facts.';

  @override
  String get onboardingTimetableTitle => 'Event Schedule';

  @override
  String get onboardingTimetableDesc =>
      'Check the full SGGW Days program and don\'t miss any event.';

  @override
  String get onboardingPermissionsTitle => 'Permissions';

  @override
  String get onboardingPermissionsDesc =>
      'The app needs access to your location for Treasure Hunt and camera for QR code scanning.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get locationPermission => 'Location';

  @override
  String get cameraPermission => 'Camera';

  @override
  String get grantPermissions => 'Grant Permissions';

  @override
  String get permissionsGranted => 'Permissions Granted';

  @override
  String get viewOnboarding => 'View Onboarding';

  @override
  String get viewOnboardingDesc => 'See the introduction again';
}
