import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// Tytuł aplikacji
  ///
  /// In pl, this message translates to:
  /// **'Dni SGGW'**
  String get appTitle;

  /// No description provided for @treasureHunt.
  ///
  /// In pl, this message translates to:
  /// **'Gra Terenowa'**
  String get treasureHunt;

  /// No description provided for @wiki.
  ///
  /// In pl, this message translates to:
  /// **'Wiedza'**
  String get wiki;

  /// No description provided for @timetable.
  ///
  /// In pl, this message translates to:
  /// **'Harmonogram'**
  String get timetable;

  /// No description provided for @notifications.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia'**
  String get notifications;

  /// No description provided for @map.
  ///
  /// In pl, this message translates to:
  /// **'Mapa'**
  String get map;

  /// No description provided for @scanQr.
  ///
  /// In pl, this message translates to:
  /// **'Skanuj QR'**
  String get scanQr;

  /// No description provided for @settings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In pl, this message translates to:
  /// **'Motyw'**
  String get theme;

  /// No description provided for @pointFound.
  ///
  /// In pl, this message translates to:
  /// **'Punkt odnaleziony!'**
  String get pointFound;

  /// No description provided for @congratulations.
  ///
  /// In pl, this message translates to:
  /// **'Gratulacje!'**
  String get congratulations;

  /// No description provided for @ok.
  ///
  /// In pl, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get cancel;

  /// No description provided for @online.
  ///
  /// In pl, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In pl, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @noConnection.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia z internetem'**
  String get noConnection;

  /// No description provided for @colorScheme.
  ///
  /// In pl, this message translates to:
  /// **'Schemat kolorów'**
  String get colorScheme;

  /// No description provided for @sggwColors.
  ///
  /// In pl, this message translates to:
  /// **'Kolory SGGW'**
  String get sggwColors;

  /// No description provided for @dynamicColors.
  ///
  /// In pl, this message translates to:
  /// **'Kolory systemowe'**
  String get dynamicColors;

  /// No description provided for @welcome.
  ///
  /// In pl, this message translates to:
  /// **'Witaj w Dniach SGGW!'**
  String get welcome;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In pl, this message translates to:
  /// **'Odkryj kampus SGGW, poznaj uczelnię i ciesz się wydarzeniami Dni SGGW!'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingTreasureHuntTitle.
  ///
  /// In pl, this message translates to:
  /// **'Gra Terenowa'**
  String get onboardingTreasureHuntTitle;

  /// No description provided for @onboardingTreasureHuntDesc.
  ///
  /// In pl, this message translates to:
  /// **'Znajdź ukryte punkty na terenie uczelni, skanuj kody QR i zdobywaj punkty. Musisz być blisko punktu, aby zeskanować kod.'**
  String get onboardingTreasureHuntDesc;

  /// No description provided for @onboardingWikiTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wiedza o SGGW'**
  String get onboardingWikiTitle;

  /// No description provided for @onboardingWikiDesc.
  ///
  /// In pl, this message translates to:
  /// **'Dowiedz się więcej o historii, wykładowcach i ciekawostkach związanych z uczelnią.'**
  String get onboardingWikiDesc;

  /// No description provided for @onboardingTimetableTitle.
  ///
  /// In pl, this message translates to:
  /// **'Harmonogram Wydarzeń'**
  String get onboardingTimetableTitle;

  /// No description provided for @onboardingTimetableDesc.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź pełny program Dni SGGW i nie przegap żadnego wydarzenia.'**
  String get onboardingTimetableDesc;

  /// No description provided for @onboardingPermissionsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Uprawnienia'**
  String get onboardingPermissionsTitle;

  /// No description provided for @onboardingPermissionsDesc.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja potrzebuje dostępu do lokalizacji do Gra Terenowej i kamery do skanowania kodów QR.'**
  String get onboardingPermissionsDesc;

  /// No description provided for @getStarted.
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In pl, this message translates to:
  /// **'Dalej'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In pl, this message translates to:
  /// **'Pomiń'**
  String get skip;

  /// No description provided for @locationPermission.
  ///
  /// In pl, this message translates to:
  /// **'Lokalizacja'**
  String get locationPermission;

  /// No description provided for @cameraPermission.
  ///
  /// In pl, this message translates to:
  /// **'Kamera'**
  String get cameraPermission;

  /// No description provided for @grantPermissions.
  ///
  /// In pl, this message translates to:
  /// **'Przyznaj uprawnienia'**
  String get grantPermissions;

  /// No description provided for @permissionsGranted.
  ///
  /// In pl, this message translates to:
  /// **'Uprawnienia przyznane'**
  String get permissionsGranted;

  /// No description provided for @viewOnboarding.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż wprowadzenie'**
  String get viewOnboarding;

  /// No description provided for @viewOnboardingDesc.
  ///
  /// In pl, this message translates to:
  /// **'Zobacz ponownie wprowadzenie do aplikacji'**
  String get viewOnboardingDesc;

  /// No description provided for @pageNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Strona nie znaleziona'**
  String get pageNotFound;

  /// No description provided for @goHome.
  ///
  /// In pl, this message translates to:
  /// **'Strona główna'**
  String get goHome;

  /// No description provided for @about.
  ///
  /// In pl, this message translates to:
  /// **'O aplikacji'**
  String get about;

  /// No description provided for @aboutDesc.
  ///
  /// In pl, this message translates to:
  /// **'Informacje o aplikacji i twórcach'**
  String get aboutDesc;

  /// No description provided for @aboutContent.
  ///
  /// In pl, this message translates to:
  /// **'Dni SGGW to oficjalna aplikacja na dzień otwarty Szkoły Głównej Gospodarstwa Wiejskiego w Warszawie. Poznaj kampus, weź udział w grze terenowej i odkryj wszystko, co SGGW ma do zaoferowania.'**
  String get aboutContent;

  /// No description provided for @developedBy.
  ///
  /// In pl, this message translates to:
  /// **'Stworzone przez SilverNET Group SGGW'**
  String get developedBy;

  /// No description provided for @distance.
  ///
  /// In pl, this message translates to:
  /// **'Odległość'**
  String get distance;

  /// No description provided for @mustBeCloser.
  ///
  /// In pl, this message translates to:
  /// **'Musisz być bliżej punktu!'**
  String get mustBeCloser;

  /// No description provided for @allPointsFound.
  ///
  /// In pl, this message translates to:
  /// **'Znalazłeś wszystkie punkty! Świetna robota w odkrywaniu kampusu SGGW!'**
  String get allPointsFound;

  /// No description provided for @scanHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia skanowań'**
  String get scanHistory;

  /// No description provided for @noScansYet.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono jeszcze żadnych punktów'**
  String get noScansYet;

  /// No description provided for @search.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj...'**
  String get search;

  /// No description provided for @allCategories.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get allCategories;

  /// No description provided for @noArticlesFound.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono artykułów'**
  String get noArticlesFound;

  /// No description provided for @noEventsOn.
  ///
  /// In pl, this message translates to:
  /// **'Brak wydarzeń na'**
  String get noEventsOn;

  /// No description provided for @campusBuildings.
  ///
  /// In pl, this message translates to:
  /// **'Budynki kampusu'**
  String get campusBuildings;

  /// No description provided for @fontSize.
  ///
  /// In pl, this message translates to:
  /// **'Rozmiar czcionki'**
  String get fontSize;

  /// No description provided for @boldText.
  ///
  /// In pl, this message translates to:
  /// **'Pogrubiony tekst'**
  String get boldText;

  /// No description provided for @adminLogin.
  ///
  /// In pl, this message translates to:
  /// **'Logowanie admina'**
  String get adminLogin;

  /// No description provided for @password.
  ///
  /// In pl, this message translates to:
  /// **'Hasło'**
  String get password;

  /// No description provided for @login.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się'**
  String get login;

  /// No description provided for @invalidPassword.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowe hasło'**
  String get invalidPassword;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
