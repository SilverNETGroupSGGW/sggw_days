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
  /// **'Mapa'**
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

  /// No description provided for @leaderboard.
  ///
  /// In pl, this message translates to:
  /// **'Ranking'**
  String get leaderboard;

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
  /// **'Poznaj kampus, wpadaj na najciekawsze wydarzenia i zbieraj małe niespodzianki po drodze.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingTreasureHuntTitle.
  ///
  /// In pl, this message translates to:
  /// **'Gra po kampusie'**
  String get onboardingTreasureHuntTitle;

  /// No description provided for @onboardingTreasureHuntDesc.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj oznaczonych miejsc na kampusie i skanuj QR-y, kiedy jesteś blisko. Każdy skan odblokowuje więcej aplikacji.'**
  String get onboardingTreasureHuntDesc;

  /// No description provided for @onboardingWikiTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wiedza o SGGW'**
  String get onboardingWikiTitle;

  /// No description provided for @onboardingWikiDesc.
  ///
  /// In pl, this message translates to:
  /// **'Zajrzyj do historii SGGW, przydatnych miejsc i kampusowych ciekawostek, kiedy tylko chcesz.'**
  String get onboardingWikiDesc;

  /// No description provided for @onboardingTimetableTitle.
  ///
  /// In pl, this message translates to:
  /// **'Harmonogram Wydarzeń'**
  String get onboardingTimetableTitle;

  /// No description provided for @onboardingTimetableDesc.
  ///
  /// In pl, this message translates to:
  /// **'Miej plan dnia pod ręką i szybko sprawdzaj, co dzieje się za chwilę.'**
  String get onboardingTimetableDesc;

  /// No description provided for @onboardingPermissionsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Prawie gotowe'**
  String get onboardingPermissionsTitle;

  /// No description provided for @onboardingPermissionsDesc.
  ///
  /// In pl, this message translates to:
  /// **'Kamera pozwala skanować QR-y. Lokalizacja pomaga sprawdzić, czy naprawdę jesteś przy punkcie gry.'**
  String get onboardingPermissionsDesc;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Bądź na bieżąco'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsDesc.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia są opcjonalne. Włącz je, aby dostawać komunikaty organizatorów i przypomnienia o wydarzeniach.'**
  String get onboardingNotificationsDesc;

  /// No description provided for @allowNotifications.
  ///
  /// In pl, this message translates to:
  /// **'Włącz powiadomienia'**
  String get allowNotifications;

  /// No description provided for @continueWithoutNotifications.
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj bez powiadomień'**
  String get continueWithoutNotifications;

  /// No description provided for @continueToMap.
  ///
  /// In pl, this message translates to:
  /// **'Przejdź do mapy'**
  String get continueToMap;

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
  /// **'Włącz kamerę i lokalizację'**
  String get grantPermissions;

  /// No description provided for @permissionsGranted.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe'**
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

  /// No description provided for @privacyPolicy.
  ///
  /// In pl, this message translates to:
  /// **'Polityka prywatności'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In pl, this message translates to:
  /// **'Jak aplikacja korzysta z uprawnień i danych'**
  String get privacyPolicyDesc;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In pl, this message translates to:
  /// **'Ta strona wyjaśnia, z jakich danych korzystają Dni SGGW, dlaczego aplikacja potrzebuje określonych uprawnień oraz jak obsługiwane są informacje zwykłych użytkowników i administratorów.'**
  String get privacyPolicyIntro;

  /// No description provided for @privacyPolicyLastUpdated.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnia aktualizacja: 22 kwietnia 2026'**
  String get privacyPolicyLastUpdated;

  /// No description provided for @privacyPolicySectionCollectedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Do jakich danych aplikacja może mieć dostęp'**
  String get privacyPolicySectionCollectedTitle;

  /// No description provided for @privacyPolicyCollectedIntro.
  ///
  /// In pl, this message translates to:
  /// **'Dni SGGW działają dla zwykłych odwiedzających bez zakładania konta, ale część funkcji korzysta z uprawnień urządzenia i usług chmurowych.'**
  String get privacyPolicyCollectedIntro;

  /// No description provided for @privacyPolicyCollectedCamera.
  ///
  /// In pl, this message translates to:
  /// **'Dostęp do kamery służy wyłącznie do skanowania kodów QR podczas gry terenowej i powiązanych interakcji eventowych.'**
  String get privacyPolicyCollectedCamera;

  /// No description provided for @privacyPolicyCollectedLocation.
  ///
  /// In pl, this message translates to:
  /// **'Dostęp do lokalizacji służy do sprawdzania, czy znajdujesz się fizycznie blisko punktu gry terenowej, zanim kod QR zostanie uznany.'**
  String get privacyPolicyCollectedLocation;

  /// No description provided for @privacyPolicyCollectedStorage.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja przechowuje lokalnie na urządzeniu ustawienia, status ukończenia wprowadzenia, wybory dotyczące powiadomień, dane z pamięci podręcznej, nazwę w rankingu oraz postęp w zbieraniu punktów. Rankingi korzystają z anonimowego identyfikatora Firebase, żeby urządzenie mogło aktualizować tylko własny wynik.'**
  String get privacyPolicyCollectedStorage;

  /// No description provided for @privacyPolicyCollectedAdmin.
  ///
  /// In pl, this message translates to:
  /// **'Funkcje administracyjne korzystają z logowania Google i usług Firebase oraz mogą przechowywać identyfikatory kont, edytowane treści i przesłane obrazy na potrzeby zarządzania wydarzeniem.'**
  String get privacyPolicyCollectedAdmin;

  /// No description provided for @privacyPolicySectionUsageTitle.
  ///
  /// In pl, this message translates to:
  /// **'Jak dane są wykorzystywane'**
  String get privacyPolicySectionUsageTitle;

  /// No description provided for @privacyPolicyUsageIntro.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja wykorzystuje dane wyłącznie do dostarczenia głównych funkcji wydarzenia oraz obsługi narzędzi administracyjnych.'**
  String get privacyPolicyUsageIntro;

  /// No description provided for @privacyPolicyUsageTreasureHunt.
  ///
  /// In pl, this message translates to:
  /// **'Dane z kamery i lokalizacji są używane, aby odwiedzający mogli odkrywać punkty gry terenowej, potwierdzać skany i odblokowywać powiązane treści.'**
  String get privacyPolicyUsageTreasureHunt;

  /// No description provided for @privacyPolicyUsageAppState.
  ///
  /// In pl, this message translates to:
  /// **'Lokalna pamięć urządzenia służy do zapamiętywania preferencji, ukończenia wprowadzenia, danych z pamięci podręcznej, wyborów dotyczących powiadomień, nazwy w rankingu oraz postępu skanowania między sesjami. Jeśli pojawisz się w rankingu, publikowana jest tylko nazwa, anonimowy identyfikator i zagregowane wyniki.'**
  String get privacyPolicyUsageAppState;

  /// No description provided for @privacyPolicyUsageAdmin.
  ///
  /// In pl, this message translates to:
  /// **'Jeśli jesteś uprawnionym administratorem, dane logowania i przesyłane treści są wykorzystywane do zarządzania wydarzeniami harmonogramu, artykułami wiki, punktami gry terenowej i obrazami.'**
  String get privacyPolicyUsageAdmin;

  /// No description provided for @privacyPolicySectionSharingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnianie i usługi zewnętrzne'**
  String get privacyPolicySectionSharingTitle;

  /// No description provided for @privacyPolicySharingIntro.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja korzysta z usług Google Firebase do uwierzytelniania, przechowywania danych w chmurze oraz hostowania obrazów dla funkcji administracyjnych.'**
  String get privacyPolicySharingIntro;

  /// No description provided for @privacyPolicySharingFirebase.
  ///
  /// In pl, this message translates to:
  /// **'Dane przesłane przez narzędzia administracyjne, rejestrację tokenów powiadomień oraz opcjonalne wpisy rankingowe mogą być przetwarzane przez Firebase Authentication, Cloud Firestore, Firebase Cloud Messaging, Cloud Functions i Firebase Storage w celu działania aplikacji.'**
  String get privacyPolicySharingFirebase;

  /// No description provided for @privacyPolicySharingLegal.
  ///
  /// In pl, this message translates to:
  /// **'Informacje mogą też zostać ujawnione, jeśli wymaga tego prawo lub jest to konieczne dla ochrony bezpieczeństwa i integralności usługi.'**
  String get privacyPolicySharingLegal;

  /// No description provided for @privacyPolicySectionChoicesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Twoje wybory'**
  String get privacyPolicySectionChoicesTitle;

  /// No description provided for @privacyPolicyChoicesIntro.
  ///
  /// In pl, this message translates to:
  /// **'Masz kontrolę nad opcjonalnymi uprawnieniami oraz lokalnie zapisanymi danymi aplikacji.'**
  String get privacyPolicyChoicesIntro;

  /// No description provided for @privacyPolicyChoicesPermissions.
  ///
  /// In pl, this message translates to:
  /// **'Możesz odmówić dostępu do kamery lub lokalizacji, ale funkcje gry terenowej zależne od tych uprawnień mogą wtedy nie działać poprawnie.'**
  String get privacyPolicyChoicesPermissions;

  /// No description provided for @privacyPolicyChoicesAdmin.
  ///
  /// In pl, this message translates to:
  /// **'Zwykli odwiedzający nie muszą tworzyć widocznego konta. Logowanie Google jest używane wyłącznie dla zatwierdzonego dostępu administratora, a rankingi mogą korzystać z anonimowego logowania Firebase w tle.'**
  String get privacyPolicyChoicesAdmin;

  /// No description provided for @privacyPolicyChoicesDevice.
  ///
  /// In pl, this message translates to:
  /// **'Możesz usunąć lokalnie zapisane dane aplikacji, czyszcząc dane aplikacji na urządzeniu albo instalując ją ponownie.'**
  String get privacyPolicyChoicesDevice;

  /// No description provided for @privacyPolicySectionContactTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kontakt'**
  String get privacyPolicySectionContactTitle;

  /// No description provided for @privacyPolicyContactIntro.
  ///
  /// In pl, this message translates to:
  /// **'Jeśli masz pytania dotyczące prywatności w Dniach SGGW, skontaktuj się z organizatorami przez oficjalne kanały kontaktowe wydarzenia.'**
  String get privacyPolicyContactIntro;

  /// No description provided for @privacyPolicyContactDetails.
  ///
  /// In pl, this message translates to:
  /// **'Pytania dotyczące prywatności należy kierować przez oficjalne kanały kontaktowe Dni SGGW lub SGGW publikowane w materiałach wydarzenia i na publicznej stronie internetowej.'**
  String get privacyPolicyContactDetails;

  /// No description provided for @privacyPolicyContactNote.
  ///
  /// In pl, this message translates to:
  /// **'Ta polityka opisuje aktualne działanie aplikacji na potrzeby testów wewnętrznych i publicznego wykorzystania podczas wydarzenia. Powinna być aktualizowana przy każdej zmianie praktyk dotyczących danych.'**
  String get privacyPolicyContactNote;

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

  /// No description provided for @noFavoriteEventsOn.
  ///
  /// In pl, this message translates to:
  /// **'Brak ulubionych wydarzeń na'**
  String get noFavoriteEventsOn;

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

  /// No description provided for @signInWithGoogle.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj przez Google'**
  String get signInWithGoogle;

  /// No description provided for @adminNotAuthorized.
  ///
  /// In pl, this message translates to:
  /// **'Twoje konto nie ma uprawnień do panelu administratora.'**
  String get adminNotAuthorized;

  /// No description provided for @adminSignInFailed.
  ///
  /// In pl, this message translates to:
  /// **'Logowanie nie powiodło się. Spróbuj ponownie.'**
  String get adminSignInFailed;

  /// No description provided for @adminSignInFailedDetail.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły: {message}'**
  String adminSignInFailedDetail(String message);

  /// No description provided for @debugEmailLoginTitle.
  ///
  /// In pl, this message translates to:
  /// **'Logowanie e-mailem w debug'**
  String get debugEmailLoginTitle;

  /// No description provided for @signInWithEmailDebug.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj e-mailem w debug'**
  String get signInWithEmailDebug;

  /// No description provided for @email.
  ///
  /// In pl, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pl, this message translates to:
  /// **'Hasło'**
  String get password;

  /// No description provided for @checkIn.
  ///
  /// In pl, this message translates to:
  /// **'Zamelduj się'**
  String get checkIn;

  /// No description provided for @checkedIn.
  ///
  /// In pl, this message translates to:
  /// **'Zameldowany'**
  String get checkedIn;

  /// No description provided for @offlineMode.
  ///
  /// In pl, this message translates to:
  /// **'Tryb offline — dane z pamięci podręcznej'**
  String get offlineMode;

  /// No description provided for @scanPageTitle.
  ///
  /// In pl, this message translates to:
  /// **'Punkt'**
  String get scanPageTitle;

  /// No description provided for @scanPageDesc.
  ///
  /// In pl, this message translates to:
  /// **'To jest punkt Dni SGGW! Otwórz aplikację Dni SGGW i zeskanuj ten kod QR w pobliżu lokalizacji, aby zdobyć punkt.'**
  String get scanPageDesc;

  /// No description provided for @scanPageOpenApp.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz aplikację'**
  String get scanPageOpenApp;

  /// No description provided for @scanPagePointNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono tego punktu.'**
  String get scanPagePointNotFound;

  /// No description provided for @invalidQrCode.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy kod QR'**
  String get invalidQrCode;

  /// No description provided for @points.
  ///
  /// In pl, this message translates to:
  /// **'Punkty'**
  String get points;

  /// No description provided for @typeTreasurePoint.
  ///
  /// In pl, this message translates to:
  /// **'Punkt skarbowy'**
  String get typeTreasurePoint;

  /// No description provided for @typeEvent.
  ///
  /// In pl, this message translates to:
  /// **'Wydarzenie'**
  String get typeEvent;

  /// No description provided for @typePointOfInterest.
  ///
  /// In pl, this message translates to:
  /// **'Punkt zainteresowania'**
  String get typePointOfInterest;

  /// No description provided for @checklist.
  ///
  /// In pl, this message translates to:
  /// **'Lista'**
  String get checklist;

  /// No description provided for @treasurePointsRemaining.
  ///
  /// In pl, this message translates to:
  /// **'{count} punktów skarbowych pozostało'**
  String treasurePointsRemaining(int count);

  /// No description provided for @nextTreasurePoint.
  ///
  /// In pl, this message translates to:
  /// **'Następny punkt skarbowy'**
  String get nextTreasurePoint;

  /// No description provided for @allTreasurePointsCollected.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie punkty skarbowe zebrane!'**
  String get allTreasurePointsCollected;

  /// No description provided for @groupedPoints.
  ///
  /// In pl, this message translates to:
  /// **'Punkty w tym miejscu'**
  String get groupedPoints;

  /// No description provided for @relatedWiki.
  ///
  /// In pl, this message translates to:
  /// **'Powiązane artykuły'**
  String get relatedWiki;

  /// No description provided for @relatedEvents.
  ///
  /// In pl, this message translates to:
  /// **'Powiązane wydarzenia'**
  String get relatedEvents;

  /// No description provided for @tutorialTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zacznij odkrywać!'**
  String get tutorialTitle;

  /// No description provided for @tutorialDesc.
  ///
  /// In pl, this message translates to:
  /// **'Zeskanuj QR przy pobliskim punkcie, żeby odblokować resztę aplikacji i zacząć zbieranie.'**
  String get tutorialDesc;

  /// No description provided for @appLocked.
  ///
  /// In pl, this message translates to:
  /// **'Zeskanuj pobliski punkt, żeby otworzyć tę zakładkę'**
  String get appLocked;

  /// No description provided for @pointCollected.
  ///
  /// In pl, this message translates to:
  /// **'Jest, punkt zebrany!'**
  String get pointCollected;

  /// No description provided for @pointCollectedDesc.
  ///
  /// In pl, this message translates to:
  /// **'Zeskanowano {pointName}!'**
  String pointCollectedDesc(String pointName);

  /// No description provided for @seeDetails.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły'**
  String get seeDetails;

  /// No description provided for @continueScan.
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj'**
  String get continueScan;

  /// No description provided for @reorderPoints.
  ///
  /// In pl, this message translates to:
  /// **'Zmień kolejność'**
  String get reorderPoints;

  /// No description provided for @trackOnMap.
  ///
  /// In pl, this message translates to:
  /// **'Śledź na mapie'**
  String get trackOnMap;

  /// No description provided for @pointLocked.
  ///
  /// In pl, this message translates to:
  /// **'Ten punkt nie jest jeszcze odblokowany'**
  String get pointLocked;

  /// No description provided for @pointDescriptionLockedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zeskanuj, żeby odkryć'**
  String get pointDescriptionLockedTitle;

  /// No description provided for @pointDescriptionLockedBody.
  ///
  /// In pl, this message translates to:
  /// **'Opis odblokuje się po zeskanowaniu kodu QR przy tym punkcie.'**
  String get pointDescriptionLockedBody;

  /// No description provided for @treasureHuntCompleteEasterEgg.
  ///
  /// In pl, this message translates to:
  /// **'Trasa po kampusie ukończona. Zapytaj ekipę o zieloną odznakę.'**
  String get treasureHuntCompleteEasterEgg;

  /// No description provided for @treasurePointNumber.
  ///
  /// In pl, this message translates to:
  /// **'Punkt skarbowy #{number}'**
  String treasurePointNumber(int number);

  /// No description provided for @adminInvalidEntries.
  ///
  /// In pl, this message translates to:
  /// **'{count} nieprawidłowych wpisów'**
  String adminInvalidEntries(int count);

  /// No description provided for @adminInvalidEntriesDesc.
  ///
  /// In pl, this message translates to:
  /// **'Te wpisy nie pasują do aktualnego schematu i wymagają naprawy.'**
  String get adminInvalidEntriesDesc;

  /// No description provided for @adminFixEntry.
  ///
  /// In pl, this message translates to:
  /// **'Napraw'**
  String get adminFixEntry;

  /// No description provided for @adminFixAll.
  ///
  /// In pl, this message translates to:
  /// **'Napraw wszystkie'**
  String get adminFixAll;

  /// No description provided for @adminFixPreviewTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd naprawy'**
  String get adminFixPreviewTitle;

  /// No description provided for @adminFixConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdź naprawę'**
  String get adminFixConfirm;

  /// No description provided for @adminRawData.
  ///
  /// In pl, this message translates to:
  /// **'Obecne (surowe)'**
  String get adminRawData;

  /// No description provided for @adminFixedData.
  ///
  /// In pl, this message translates to:
  /// **'Naprawione'**
  String get adminFixedData;

  /// No description provided for @adminDeleteEntry.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get adminDeleteEntry;

  /// No description provided for @adminEntryFixed.
  ///
  /// In pl, this message translates to:
  /// **'Wpis naprawiony pomyślnie'**
  String get adminEntryFixed;

  /// No description provided for @adminAllEntriesFixed.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie wpisy naprawione pomyślnie'**
  String get adminAllEntriesFixed;

  /// No description provided for @continueWithoutTreasureHunt.
  ///
  /// In pl, this message translates to:
  /// **'Używaj apki bez gry'**
  String get continueWithoutTreasureHunt;

  /// No description provided for @skipTreasureHuntDialogTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pominąć grę po kampusie?'**
  String get skipTreasureHuntDialogTitle;

  /// No description provided for @skipTreasureHuntDialogBody.
  ///
  /// In pl, this message translates to:
  /// **'Nadal możesz korzystać z mapy, wiedzy i harmonogramu. Zbieranie QR-ów zostanie opcjonalne, ale rankingi i nagrody z gry nie będą się wtedy liczyć.'**
  String get skipTreasureHuntDialogBody;

  /// No description provided for @skipTreasureHuntEnabledSnack.
  ///
  /// In pl, this message translates to:
  /// **'Odblokowanie gry terenowej jest teraz opcjonalne.'**
  String get skipTreasureHuntEnabledSnack;

  /// No description provided for @skipTreasureHuntSettingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pomiń blokadę gry terenowej'**
  String get skipTreasureHuntSettingTitle;

  /// No description provided for @skipTreasureHuntSettingDesc.
  ///
  /// In pl, this message translates to:
  /// **'Pokazuj punkty na mapie, wiedzę i harmonogram bez skanowania pierwszego punktu skarbu.'**
  String get skipTreasureHuntSettingDesc;

  /// No description provided for @eventRemindersSettingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia o wydarzeniach'**
  String get eventRemindersSettingTitle;

  /// No description provided for @eventRemindersSettingDesc.
  ///
  /// In pl, this message translates to:
  /// **'Powiadom mnie 15 minut przed ulubionymi wydarzeniami z harmonogramu.'**
  String get eventRemindersSettingDesc;

  /// No description provided for @eventTags.
  ///
  /// In pl, this message translates to:
  /// **'Tagi'**
  String get eventTags;

  /// No description provided for @eventRemindersUnsupportedDesc.
  ///
  /// In pl, this message translates to:
  /// **'Tylko w aplikacji mobilnej.'**
  String get eventRemindersUnsupportedDesc;

  /// No description provided for @eventRemindersEnabledSnack.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia dla ulubionych wydarzeń są włączone.'**
  String get eventRemindersEnabledSnack;

  /// No description provided for @pushNotificationsSettingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia organizatorów'**
  String get pushNotificationsSettingTitle;

  /// No description provided for @pushNotificationsSettingDesc.
  ///
  /// In pl, this message translates to:
  /// **'Otrzymuj ważne komunikaty wysyłane przez organizatorów wydarzenia.'**
  String get pushNotificationsSettingDesc;

  /// No description provided for @pushNotificationsEnabledSnack.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia organizatorów są włączone.'**
  String get pushNotificationsEnabledSnack;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In pl, this message translates to:
  /// **'Nie przyznano uprawnienia do powiadomień.'**
  String get notificationPermissionDenied;

  /// No description provided for @leaderboardOverall.
  ///
  /// In pl, this message translates to:
  /// **'Wszystko'**
  String get leaderboardOverall;

  /// No description provided for @leaderboardTreasureHunt.
  ///
  /// In pl, this message translates to:
  /// **'Gra'**
  String get leaderboardTreasureHunt;

  /// No description provided for @leaderboardDisplayName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa w rankingu'**
  String get leaderboardDisplayName;

  /// No description provided for @leaderboardEditName.
  ///
  /// In pl, this message translates to:
  /// **'Zmień nazwę'**
  String get leaderboardEditName;

  /// No description provided for @leaderboardSaveName.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get leaderboardSaveName;

  /// No description provided for @leaderboardNoEntries.
  ///
  /// In pl, this message translates to:
  /// **'Brak wyników'**
  String get leaderboardNoEntries;

  /// No description provided for @leaderboardYou.
  ///
  /// In pl, this message translates to:
  /// **'Ty'**
  String get leaderboardYou;

  /// No description provided for @leaderboardScore.
  ///
  /// In pl, this message translates to:
  /// **'{count} pkt'**
  String leaderboardScore(int count);

  /// No description provided for @leaderboardFoundPoints.
  ///
  /// In pl, this message translates to:
  /// **'{count} punktów'**
  String leaderboardFoundPoints(int count);

  /// No description provided for @leaderboardTreasurePoints.
  ///
  /// In pl, this message translates to:
  /// **'{count} skarbów'**
  String leaderboardTreasurePoints(int count);

  /// No description provided for @leaderboardCheckIns.
  ///
  /// In pl, this message translates to:
  /// **'{count} meldunków'**
  String leaderboardCheckIns(int count);

  /// No description provided for @permissionDeniedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Potrzebujemy jeszcze jednej rzeczy'**
  String get permissionDeniedTitle;

  /// No description provided for @permissionDeniedCameraBody.
  ///
  /// In pl, this message translates to:
  /// **'Kamera pozwala skanować QR-y podczas gry po kampusie.'**
  String get permissionDeniedCameraBody;

  /// No description provided for @permissionDeniedLocationBody.
  ///
  /// In pl, this message translates to:
  /// **'Lokalizacja potwierdza, że jesteś wystarczająco blisko punktu.'**
  String get permissionDeniedLocationBody;

  /// No description provided for @permissionDeniedOpenSettings.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz ustawienia'**
  String get permissionDeniedOpenSettings;

  /// No description provided for @permissionDeniedRetry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get permissionDeniedRetry;

  /// No description provided for @cameraLoading.
  ///
  /// In pl, this message translates to:
  /// **'Uruchamianie kamery...'**
  String get cameraLoading;
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
