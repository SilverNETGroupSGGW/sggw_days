// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Dni SGGW';

  @override
  String get treasureHunt => 'Gra Terenowa';

  @override
  String get wiki => 'Wiedza';

  @override
  String get timetable => 'Harmonogram';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get map => 'Mapa';

  @override
  String get scanQr => 'Skanuj QR';

  @override
  String get points => 'Punkty';

  @override
  String get settings => 'Ustawienia';

  @override
  String get language => 'Język';

  @override
  String get theme => 'Motyw';

  @override
  String score(int value) {
    return 'Wynik: $value';
  }

  @override
  String get pointFound => 'Punkt odnaleziony!';

  @override
  String get congratulations => 'Gratulacje!';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Anuluj';
}
