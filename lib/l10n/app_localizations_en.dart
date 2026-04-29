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
      'Explore the campus, catch the best events, and collect a few surprises along the way.';

  @override
  String get onboardingTreasureHuntTitle => 'Campus Hunt';

  @override
  String get onboardingTreasureHuntDesc =>
      'Find marked spots around campus and scan their QR codes when you get close. Each scan unlocks more of the app.';

  @override
  String get onboardingWikiTitle => 'SGGW Knowledge';

  @override
  String get onboardingWikiDesc =>
      'Peek into SGGW stories, useful places and campus facts whenever you need them.';

  @override
  String get onboardingTimetableTitle => 'Event Schedule';

  @override
  String get onboardingTimetableDesc =>
      'Keep the day in your pocket and jump to the next thing without hunting through posters.';

  @override
  String get onboardingPermissionsTitle => 'Almost ready';

  @override
  String get onboardingPermissionsDesc =>
      'Camera lets you scan QR codes. Location helps confirm you are actually by a hunt point.';

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
  String get grantPermissions => 'Allow camera and location';

  @override
  String get permissionsGranted => 'All set';

  @override
  String get viewOnboarding => 'View Onboarding';

  @override
  String get viewOnboardingDesc => 'See the introduction again';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDesc => 'How the app handles permissions and data';

  @override
  String get privacyPolicyIntro =>
      'This page explains what data Dni SGGW uses, why the app needs certain permissions, and how information is handled for regular visitors and administrators.';

  @override
  String get privacyPolicyLastUpdated => 'Last updated: 22 April 2026';

  @override
  String get privacyPolicySectionCollectedTitle =>
      'What data the app can access';

  @override
  String get privacyPolicyCollectedIntro =>
      'Dni SGGW is designed to work without requiring an account for regular visitors, but some features rely on device permissions and cloud services.';

  @override
  String get privacyPolicyCollectedCamera =>
      'Camera access is used only to scan QR codes during the treasure hunt and related event interactions.';

  @override
  String get privacyPolicyCollectedLocation =>
      'Location access is used to verify that you are physically near a treasure hunt point before a QR code can be accepted.';

  @override
  String get privacyPolicyCollectedStorage =>
      'The app stores settings, onboarding status, cached content, and collected progress locally on your device.';

  @override
  String get privacyPolicyCollectedAdmin =>
      'Administrator features use Google sign-in together with Firebase services and may store account identifiers, edited content, and uploaded images for event management.';

  @override
  String get privacyPolicySectionUsageTitle => 'How the data is used';

  @override
  String get privacyPolicyUsageIntro =>
      'The app uses data only to deliver the core event experience and to operate the administration tools.';

  @override
  String get privacyPolicyUsageTreasureHunt =>
      'Camera and location data are used to let visitors discover treasure hunt points, validate scans, and unlock related content.';

  @override
  String get privacyPolicyUsageAppState =>
      'Local device storage is used to remember your preferences, onboarding completion, cached data, and scan progress between sessions.';

  @override
  String get privacyPolicyUsageAdmin =>
      'If you are an authorized administrator, sign-in data and uploaded content are used to manage timetable entries, wiki articles, treasure hunt points, and images.';

  @override
  String get privacyPolicySectionSharingTitle =>
      'Sharing and third-party services';

  @override
  String get privacyPolicySharingIntro =>
      'The app relies on Google Firebase services to provide authentication, cloud data storage, and image hosting for administration features.';

  @override
  String get privacyPolicySharingFirebase =>
      'Data submitted through administrator tools may be processed by Firebase Authentication, Cloud Firestore, and Firebase Storage as part of operating the app.';

  @override
  String get privacyPolicySharingLegal =>
      'Information may also be disclosed if required by law or when necessary to protect the security and integrity of the service.';

  @override
  String get privacyPolicySectionChoicesTitle => 'Your choices';

  @override
  String get privacyPolicyChoicesIntro =>
      'You stay in control of optional permissions and locally stored app data.';

  @override
  String get privacyPolicyChoicesPermissions =>
      'You can deny camera or location permissions, but treasure hunt features that depend on them may stop working correctly.';

  @override
  String get privacyPolicyChoicesAdmin =>
      'Regular visitors do not need to create an account. Google sign-in is only used for approved administrator access.';

  @override
  String get privacyPolicyChoicesDevice =>
      'You can clear locally stored app data by removing the app data from your device or reinstalling the application.';

  @override
  String get privacyPolicySectionContactTitle => 'Contact';

  @override
  String get privacyPolicyContactIntro =>
      'If you have privacy-related questions about Dni SGGW, contact the organizers using the official event contact channels.';

  @override
  String get privacyPolicyContactDetails =>
      'Privacy-related questions should be sent through the official SGGW Days or SGGW event contact channels published with the event materials and public website.';

  @override
  String get privacyPolicyContactNote =>
      'This policy is intended to describe the current app behavior for internal testing and public event use. It should be updated whenever the app\'s data practices change.';

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
  String adminSignInFailedDetail(String message) {
    return 'Details: $message';
  }

  @override
  String get debugEmailLoginTitle => 'Debug email login';

  @override
  String get signInWithEmailDebug => 'Sign in with email in debug';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

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
      'Scan a nearby QR code to open the rest of the app and start collecting points.';

  @override
  String get appLocked => 'Scan one nearby point to open this tab';

  @override
  String get pointCollected => 'Nice, point collected!';

  @override
  String pointCollectedDesc(String pointName) {
    return 'You scanned $pointName!';
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

  @override
  String get continueWithoutTreasureHunt => 'Use the app without the hunt';

  @override
  String get skipTreasureHuntDialogTitle => 'Skip the campus hunt?';

  @override
  String get skipTreasureHuntDialogBody =>
      'You can still use the map, wiki and timetable. QR collecting stays optional, but hunt rankings and rewards will not count for you.';

  @override
  String get skipTreasureHuntEnabledSnack =>
      'Treasure hunt unlock is now optional.';

  @override
  String get skipTreasureHuntSettingTitle => 'Skip treasure hunt gate';

  @override
  String get skipTreasureHuntSettingDesc =>
      'Show map points, wiki and timetable without scanning the first treasure point.';

  @override
  String get permissionDeniedTitle => 'We need one more thing';

  @override
  String get permissionDeniedCameraBody =>
      'Camera access lets you scan QR codes during the campus hunt.';

  @override
  String get permissionDeniedLocationBody =>
      'Location access confirms you are close enough to collect a point.';

  @override
  String get permissionDeniedOpenSettings => 'Open settings';

  @override
  String get permissionDeniedRetry => 'Try again';

  @override
  String get cameraLoading => 'Starting camera...';
}
