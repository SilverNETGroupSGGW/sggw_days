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
  String get treasureHunt => 'Map';

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
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

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

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get goHome => 'Go Home';

  @override
  String get about => 'About';

  @override
  String get aboutDesc => 'App information and credits';

  @override
  String get aboutContent =>
      'SGGW Days is the official app for the Warsaw University of Life Sciences open days event. Explore the campus, participate in the treasure hunt, and discover everything SGGW has to offer.';

  @override
  String get developedBy => 'Developed by SilverNET Group SGGW';

  @override
  String get distance => 'Distance';

  @override
  String get mustBeCloser => 'You must be closer to the treasure point!';

  @override
  String get allPointsFound =>
      'You found all the treasure points! Amazing job exploring the SGGW campus!';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get noScansYet => 'No points found yet';

  @override
  String get search => 'Search...';

  @override
  String get allCategories => 'All';

  @override
  String get noArticlesFound => 'No articles found';

  @override
  String get noEventsOn => 'No events on';

  @override
  String get campusBuildings => 'Campus Buildings';

  @override
  String get fontSize => 'Font Size';

  @override
  String get boldText => 'Bold Text';

  @override
  String get adminLogin => 'Admin Login';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get adminNotAuthorized =>
      'Your account is not authorised to access the admin panel.';

  @override
  String get adminSignInFailed => 'Sign-in failed. Please try again.';

  @override
  String get checkIn => 'Check In';

  @override
  String get checkedIn => 'Checked in';

  @override
  String get offlineMode => 'Offline mode — using cached data';

  @override
  String get scanPageTitle => 'Point';

  @override
  String get scanPageDesc =>
      'This is a treasure hunt point from SGGW Days! Open the SGGW Days app and scan this QR code near the location to collect the point.';

  @override
  String get scanPageOpenApp => 'Open App';

  @override
  String get scanPagePointNotFound => 'This point was not found.';

  @override
  String get invalidQrCode => 'Invalid QR code';

  @override
  String get points => 'Points';

  @override
  String get typeTreasurePoint => 'Treasure Point';

  @override
  String get typeEvent => 'Event';

  @override
  String get typePointOfInterest => 'Point of Interest';

  @override
  String get checklist => 'Checklist';

  @override
  String treasurePointsRemaining(int count) {
    return '$count treasure points remaining';
  }

  @override
  String get nextTreasurePoint => 'Next Treasure Point';

  @override
  String get allTreasurePointsCollected => 'All treasure points collected!';

  @override
  String get relatedWiki => 'Related Articles';

  @override
  String get relatedEvents => 'Related Events';

  @override
  String get tutorialTitle => 'Start Exploring!';

  @override
  String get tutorialDesc =>
      'Scan your first QR code at a nearby point to unlock the full app experience.';

  @override
  String get appLocked => 'Scan your first point to unlock';

  @override
  String get pointCollected => 'Point Collected!';

  @override
  String pointCollectedDesc(String pointName) {
    return 'You successfully scanned $pointName!';
  }

  @override
  String get seeDetails => 'See Details';

  @override
  String get continueScan => 'Continue';

  @override
  String get reorderPoints => 'Reorder Points';

  @override
  String get trackOnMap => 'Track on Map';

  @override
  String get pointLocked => 'This point is not yet unlocked';

  @override
  String treasurePointNumber(int number) {
    return 'Treasure Point #$number';
  }

  @override
  String adminInvalidEntries(int count) {
    return '$count invalid entries';
  }

  @override
  String get adminInvalidEntriesDesc =>
      'These entries do not match the current schema and need to be fixed.';

  @override
  String get adminFixEntry => 'Fix';

  @override
  String get adminFixAll => 'Fix All';

  @override
  String get adminFixPreviewTitle => 'Fix Preview';

  @override
  String get adminFixConfirm => 'Confirm Fix';

  @override
  String get adminRawData => 'Current (raw)';

  @override
  String get adminFixedData => 'Fixed';

  @override
  String get adminDeleteEntry => 'Delete';

  @override
  String get adminEntryFixed => 'Entry fixed successfully';

  @override
  String get adminAllEntriesFixed => 'All entries fixed successfully';
}
