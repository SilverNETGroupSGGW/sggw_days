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
}
