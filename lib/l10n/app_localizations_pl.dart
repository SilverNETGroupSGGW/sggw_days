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
  String get treasureHunt => 'Mapa';

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
  String get settings => 'Ustawienia';

  @override
  String get language => 'Język';

  @override
  String get theme => 'Motyw';

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

  @override
  String get pageNotFound => 'Strona nie znaleziona';

  @override
  String get goHome => 'Strona główna';

  @override
  String get about => 'O aplikacji';

  @override
  String get aboutDesc => 'Informacje o aplikacji i twórcach';

  @override
  String get aboutContent =>
      'Dni SGGW to oficjalna aplikacja na dzień otwarty Szkoły Głównej Gospodarstwa Wiejskiego w Warszawie. Poznaj kampus, weź udział w grze terenowej i odkryj wszystko, co SGGW ma do zaoferowania.';

  @override
  String get developedBy => 'Stworzone przez SilverNET Group SGGW';

  @override
  String get distance => 'Odległość';

  @override
  String get mustBeCloser => 'Musisz być bliżej punktu!';

  @override
  String get allPointsFound =>
      'Znalazłeś wszystkie punkty! Świetna robota w odkrywaniu kampusu SGGW!';

  @override
  String get scanHistory => 'Historia skanowań';

  @override
  String get noScansYet => 'Nie znaleziono jeszcze żadnych punktów';

  @override
  String get search => 'Szukaj...';

  @override
  String get allCategories => 'Wszystkie';

  @override
  String get noArticlesFound => 'Nie znaleziono artykułów';

  @override
  String get noEventsOn => 'Brak wydarzeń na';

  @override
  String get campusBuildings => 'Budynki kampusu';

  @override
  String get fontSize => 'Rozmiar czcionki';

  @override
  String get boldText => 'Pogrubiony tekst';

  @override
  String get adminLogin => 'Logowanie admina';

  @override
  String get signInWithGoogle => 'Zaloguj przez Google';

  @override
  String get adminNotAuthorized =>
      'Twoje konto nie ma uprawnień do panelu administratora.';

  @override
  String get adminSignInFailed =>
      'Logowanie nie powiodło się. Spróbuj ponownie.';

  @override
  String get checkIn => 'Zamelduj się';

  @override
  String get checkedIn => 'Zameldowany';

  @override
  String get offlineMode => 'Tryb offline — dane z pamięci podręcznej';

  @override
  String get scanPageTitle => 'Punkt';

  @override
  String get scanPageDesc =>
      'To jest punkt Dni SGGW! Otwórz aplikację Dni SGGW i zeskanuj ten kod QR w pobliżu lokalizacji, aby zdobyć punkt.';

  @override
  String get scanPageOpenApp => 'Otwórz aplikację';

  @override
  String get scanPagePointNotFound => 'Nie znaleziono tego punktu.';

  @override
  String get invalidQrCode => 'Nieprawidłowy kod QR';

  @override
  String get points => 'Punkty';

  @override
  String get typeTreasurePoint => 'Punkt skarbowy';

  @override
  String get typeEvent => 'Wydarzenie';

  @override
  String get typePointOfInterest => 'Punkt zainteresowania';

  @override
  String get checklist => 'Lista';

  @override
  String treasurePointsRemaining(int count) {
    return '$count punktów skarbowych pozostało';
  }

  @override
  String get nextTreasurePoint => 'Następny punkt skarbowy';

  @override
  String get allTreasurePointsCollected => 'Wszystkie punkty skarbowe zebrane!';

  @override
  String get relatedWiki => 'Powiązane artykuły';

  @override
  String get relatedEvents => 'Powiązane wydarzenia';

  @override
  String get tutorialTitle => 'Zacznij odkrywać!';

  @override
  String get tutorialDesc =>
      'Zeskanuj swój pierwszy kod QR przy pobliskim punkcie, aby odblokować pełne doświadczenie aplikacji.';

  @override
  String get appLocked => 'Zeskanuj pierwszy punkt, aby odblokować';

  @override
  String get pointCollected => 'Punkt zebrany!';

  @override
  String pointCollectedDesc(String pointName) {
    return 'Pomyślnie zeskanowałeś $pointName!';
  }

  @override
  String get seeDetails => 'Szczegóły';

  @override
  String get continueScan => 'Kontynuuj';

  @override
  String get reorderPoints => 'Zmień kolejność';

  @override
  String get trackOnMap => 'Śledź na mapie';

  @override
  String get pointLocked => 'Ten punkt nie jest jeszcze odblokowany';

  @override
  String treasurePointNumber(int number) {
    return 'Punkt skarbowy #$number';
  }

  @override
  String adminInvalidEntries(int count) {
    return '$count nieprawidłowych wpisów';
  }

  @override
  String get adminInvalidEntriesDesc =>
      'Te wpisy nie pasują do aktualnego schematu i wymagają naprawy.';

  @override
  String get adminFixEntry => 'Napraw';

  @override
  String get adminFixAll => 'Napraw wszystkie';

  @override
  String get adminFixPreviewTitle => 'Podgląd naprawy';

  @override
  String get adminFixConfirm => 'Zatwierdź naprawę';

  @override
  String get adminRawData => 'Obecne (surowe)';

  @override
  String get adminFixedData => 'Naprawione';

  @override
  String get adminDeleteEntry => 'Usuń';

  @override
  String get adminEntryFixed => 'Wpis naprawiony pomyślnie';

  @override
  String get adminAllEntriesFixed => 'Wszystkie wpisy naprawione pomyślnie';
}
