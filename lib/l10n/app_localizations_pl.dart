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

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get noConnection => 'Brak połączenia z internetem';

  @override
  String get colorScheme => 'Schemat kolorów';

  @override
  String get sggwColors => 'Kolory SGGW';

  @override
  String get dynamicColors => 'Kolory systemowe';

  @override
  String get welcome => 'Witaj w Dniach SGGW!';

  @override
  String get onboardingWelcomeDesc =>
      'Odkryj kampus SGGW, poznaj uczelnię i ciesz się wydarzeniami Dni SGGW!';

  @override
  String get onboardingTreasureHuntTitle => 'Gra Terenowa';

  @override
  String get onboardingTreasureHuntDesc =>
      'Znajdź ukryte punkty na terenie uczelni, skanuj kody QR i zdobywaj punkty. Musisz być blisko punktu, aby zeskanować kod.';

  @override
  String get onboardingWikiTitle => 'Wiedza o SGGW';

  @override
  String get onboardingWikiDesc =>
      'Dowiedz się więcej o historii, wykładowcach i ciekawostkach związanych z uczelnią.';

  @override
  String get onboardingTimetableTitle => 'Harmonogram Wydarzeń';

  @override
  String get onboardingTimetableDesc =>
      'Sprawdź pełny program Dni SGGW i nie przegap żadnego wydarzenia.';

  @override
  String get onboardingPermissionsTitle => 'Uprawnienia';

  @override
  String get onboardingPermissionsDesc =>
      'Aplikacja potrzebuje dostępu do lokalizacji do Gra Terenowej i kamery do skanowania kodów QR.';

  @override
  String get getStarted => 'Rozpocznij';

  @override
  String get next => 'Dalej';

  @override
  String get skip => 'Pomiń';

  @override
  String get locationPermission => 'Lokalizacja';

  @override
  String get cameraPermission => 'Kamera';

  @override
  String get grantPermissions => 'Przyznaj uprawnienia';

  @override
  String get permissionsGranted => 'Uprawnienia przyznane';

  @override
  String get viewOnboarding => 'Pokaż wprowadzenie';

  @override
  String get viewOnboardingDesc => 'Zobacz ponownie wprowadzenie do aplikacji';
}
