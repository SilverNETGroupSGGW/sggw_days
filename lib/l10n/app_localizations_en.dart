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
  String get onboardingTitle1 => 'Treasure Hunt';

  @override
  String get onboardingDesc1 =>
      'Find hidden points on campus, scan QR codes and earn points. You must be close to a point to scan its code.';

  @override
  String get onboardingTitle2 => 'SGGW Knowledge';

  @override
  String get onboardingDesc2 =>
      'Learn more about the university\'s history, lecturers and interesting facts.';

  @override
  String get onboardingTitle3 => 'Event Schedule';

  @override
  String get onboardingDesc3 =>
      'Check the full SGGW Days program and don\'t miss any event.';

  @override
  String get onboardingTitle4 => 'Permissions';

  @override
  String get onboardingDesc4 =>
      'The app needs access to your location (treasure hunt) and camera (QR scanning).';

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
}
