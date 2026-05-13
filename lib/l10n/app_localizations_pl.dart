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
      'Poznaj kampus, wpadaj na najciekawsze wydarzenia i zbieraj małe niespodzianki po drodze.';

  @override
  String get onboardingTreasureHuntTitle => 'Gra po kampusie';

  @override
  String get onboardingTreasureHuntDesc =>
      'Szukaj oznaczonych miejsc na kampusie i skanuj QR-y, kiedy jesteś blisko. Zeskanuj wszystkie punkty skarbowe i zamelduj się na jednym wydarzeniu, aby odebrać małą nagrodę.';

  @override
  String get onboardingWikiTitle => 'Wiedza o SGGW';

  @override
  String get onboardingWikiDesc =>
      'Zajrzyj do historii SGGW, przydatnych miejsc i kampusowych ciekawostek, kiedy tylko chcesz.';

  @override
  String get onboardingTimetableTitle => 'Harmonogram Wydarzeń';

  @override
  String get onboardingTimetableDesc =>
      'Miej plan dnia pod ręką i szybko sprawdzaj, co dzieje się za chwilę.';

  @override
  String get onboardingPermissionsTitle => 'Prawie gotowe';

  @override
  String get onboardingPermissionsDesc =>
      'Kamera pozwala skanować QR-y. Lokalizacja pomaga sprawdzić, czy naprawdę jesteś przy punkcie gry.';

  @override
  String get onboardingNotificationsTitle => 'Bądź na bieżąco';

  @override
  String get onboardingNotificationsDesc =>
      'Powiadomienia są opcjonalne. Włącz je, aby dostawać komunikaty organizatorów i przypomnienia o wydarzeniach.';

  @override
  String get allowNotifications => 'Włącz powiadomienia';

  @override
  String get continueWithoutNotifications => 'Kontynuuj bez powiadomień';

  @override
  String get continueToMap => 'Przejdź do mapy';

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
  String get grantPermissions => 'Włącz kamerę i lokalizację';

  @override
  String get permissionsGranted => 'Gotowe';

  @override
  String get viewOnboarding => 'Pokaż wprowadzenie';

  @override
  String get viewOnboardingDesc => 'Zobacz ponownie wprowadzenie do aplikacji';

  @override
  String get privacyPolicy => 'Polityka prywatności';

  @override
  String get privacyPolicyDesc => 'Jak aplikacja korzysta z uprawnień i danych';

  @override
  String get privacyPolicyIntro =>
      'Ta strona wyjaśnia, z jakich danych korzystają Dni SGGW, dlaczego aplikacja potrzebuje określonych uprawnień oraz jak obsługiwane są informacje zwykłych użytkowników i administratorów.';

  @override
  String get privacyPolicyLastUpdated =>
      'Ostatnia aktualizacja: 22 kwietnia 2026';

  @override
  String get privacyPolicySectionCollectedTitle =>
      'Do jakich danych aplikacja może mieć dostęp';

  @override
  String get privacyPolicyCollectedIntro =>
      'Dni SGGW działają dla zwykłych odwiedzających bez zakładania konta, ale część funkcji korzysta z uprawnień urządzenia i usług chmurowych.';

  @override
  String get privacyPolicyCollectedCamera =>
      'Dostęp do kamery służy wyłącznie do skanowania kodów QR podczas gry terenowej i powiązanych interakcji eventowych.';

  @override
  String get privacyPolicyCollectedLocation =>
      'Dostęp do lokalizacji służy do sprawdzania, czy znajdujesz się fizycznie blisko punktu gry terenowej, zanim kod QR zostanie uznany.';

  @override
  String get privacyPolicyCollectedStorage =>
      'Aplikacja przechowuje lokalnie na urządzeniu ustawienia, status ukończenia wprowadzenia, wybory dotyczące powiadomień, dane z pamięci podręcznej, postęp skanowania, zameldowania na wydarzeniach oraz identyfikator urządzenia do odbioru nagrody.';

  @override
  String get privacyPolicyCollectedAdmin =>
      'Funkcje administracyjne korzystają z logowania Google i usług Firebase oraz mogą przechowywać identyfikatory kont, edytowane treści i przesłane obrazy na potrzeby zarządzania wydarzeniem.';

  @override
  String get privacyPolicySectionUsageTitle => 'Jak dane są wykorzystywane';

  @override
  String get privacyPolicyUsageIntro =>
      'Aplikacja wykorzystuje dane wyłącznie do dostarczenia głównych funkcji wydarzenia oraz obsługi narzędzi administracyjnych.';

  @override
  String get privacyPolicyUsageTreasureHunt =>
      'Dane z kamery i lokalizacji są używane, aby odwiedzający mogli odkrywać punkty gry terenowej, potwierdzać skany i odblokowywać powiązane treści.';

  @override
  String get privacyPolicyUsageAppState =>
      'Lokalna pamięć urządzenia służy do zapamiętywania preferencji, ukończenia wprowadzenia, danych z pamięci podręcznej, wyborów dotyczących powiadomień oraz postępu skanowania między sesjami.';

  @override
  String get privacyPolicyUsageAdmin =>
      'Jeśli jesteś uprawnionym administratorem, dane logowania i przesyłane treści są wykorzystywane do zarządzania wydarzeniami harmonogramu, artykułami wiki, punktami gry terenowej i obrazami.';

  @override
  String get privacyPolicySectionSharingTitle =>
      'Udostępnianie i usługi zewnętrzne';

  @override
  String get privacyPolicySharingIntro =>
      'Aplikacja korzysta z usług Google Firebase do uwierzytelniania, przechowywania danych w chmurze oraz hostowania obrazów dla funkcji administracyjnych.';

  @override
  String get privacyPolicySharingFirebase =>
      'Dane przesłane przez narzędzia administracyjne, rejestrację tokenów powiadomień oraz weryfikację nagrody mogą być przetwarzane przez Firebase Authentication, Cloud Firestore, Firebase Cloud Messaging, Cloud Functions i Firebase Storage w celu działania aplikacji.';

  @override
  String get privacyPolicySharingLegal =>
      'Informacje mogą też zostać ujawnione, jeśli wymaga tego prawo lub jest to konieczne dla ochrony bezpieczeństwa i integralności usługi.';

  @override
  String get privacyPolicySectionChoicesTitle => 'Twoje wybory';

  @override
  String get privacyPolicyChoicesIntro =>
      'Masz kontrolę nad opcjonalnymi uprawnieniami oraz lokalnie zapisanymi danymi aplikacji.';

  @override
  String get privacyPolicyChoicesPermissions =>
      'Możesz odmówić dostępu do kamery lub lokalizacji, ale funkcje gry terenowej zależne od tych uprawnień mogą wtedy nie działać poprawnie.';

  @override
  String get privacyPolicyChoicesAdmin =>
      'Zwykli odwiedzający nie muszą tworzyć widocznego konta. Logowanie Google jest używane wyłącznie dla zatwierdzonego dostępu administratora.';

  @override
  String get privacyPolicyChoicesDevice =>
      'Możesz usunąć lokalnie zapisane dane aplikacji, czyszcząc dane aplikacji na urządzeniu albo instalując ją ponownie.';

  @override
  String get privacyPolicySectionContactTitle => 'Kontakt';

  @override
  String get privacyPolicyContactIntro =>
      'Jeśli masz pytania dotyczące prywatności w Dniach SGGW, skontaktuj się z organizatorami przez oficjalne kanały kontaktowe wydarzenia.';

  @override
  String get privacyPolicyContactDetails =>
      'Pytania dotyczące prywatności należy kierować przez oficjalne kanały kontaktowe Dni SGGW lub SGGW publikowane w materiałach wydarzenia i na publicznej stronie internetowej.';

  @override
  String get privacyPolicyContactNote =>
      'Ta polityka opisuje aktualne działanie aplikacji na potrzeby testów wewnętrznych i publicznego wykorzystania podczas wydarzenia. Powinna być aktualizowana przy każdej zmianie praktyk dotyczących danych.';

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
  String get noResultsFound => 'Brak wyników';

  @override
  String get allCategories => 'Wszystkie';

  @override
  String get noArticlesFound => 'Nie znaleziono artykułów';

  @override
  String get noEventsOn => 'Brak wydarzeń na';

  @override
  String get noFavoriteEventsOn => 'Brak ulubionych wydarzeń na';

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
  String adminSignInFailedDetail(String message) {
    return 'Szczegóły: $message';
  }

  @override
  String get debugEmailLoginTitle => 'Logowanie e-mailem w debug';

  @override
  String get signInWithEmailDebug => 'Zaloguj e-mailem w debug';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Hasło';

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
  String get groupedPoints => 'Punkty w tym miejscu';

  @override
  String get relatedWiki => 'Powiązane artykuły';

  @override
  String get relatedEvents => 'Powiązane wydarzenia';

  @override
  String get relatedPoints => 'Powiązane punkty';

  @override
  String get tutorialTitle => 'Zacznij odkrywać!';

  @override
  String get tutorialDesc =>
      'Zeskanuj pierwszy pobliski QR skarbu, aby odkryć punkty kampusu. Ukończ trasę i jedno zameldowanie na wydarzeniu, aby odebrać małą nagrodę.';

  @override
  String get appLocked => 'Zeskanuj pobliski punkt, żeby otworzyć tę zakładkę';

  @override
  String get pointCollected => 'Jest, punkt zebrany!';

  @override
  String pointCollectedDesc(String pointName) {
    return 'Zeskanowano $pointName!';
  }

  @override
  String get seeDetails => 'Szczegóły';

  @override
  String get continueScan => 'Kontynuuj';

  @override
  String get pointAlreadyScanned => 'Ten punkt został już zeskanowany.';

  @override
  String get reorderPoints => 'Zmień kolejność';

  @override
  String get trackOnMap => 'Śledź na mapie';

  @override
  String get pointLocked => 'Ten punkt nie jest jeszcze odblokowany';

  @override
  String get treasureHuntCompleteEasterEgg =>
      'Trasa po kampusie ukończona. Pokaż QR nagrody osobie z Silver.NET.';

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

  @override
  String get continueWithoutTreasureHunt => 'Używaj apki bez gry';

  @override
  String get skipTreasureHuntDialogTitle => 'Pominąć grę po kampusie?';

  @override
  String get skipTreasureHuntDialogBody =>
      'Nadal możesz korzystać z mapy, wiedzy i harmonogramu. Skanowanie QR-ów skarbu i zameldowania do gry na wydarzeniach zostaną wyłączone, więc nie weźmiesz udziału w grze ani nie odbierzesz nagród za grę.';

  @override
  String get skipTreasureHuntEnabledSnack =>
      'Udział w grze terenowej jest wyłączony.';

  @override
  String get skipTreasureHuntSettingTitle => 'Używaj mapy bez gry terenowej';

  @override
  String get skipTreasureHuntSettingDesc =>
      'Pokazuj punkty kampusu bez skanowania QR-ów skarbu. To wyłącza udział w grze, zameldowania do gry na wydarzeniach i odbiór nagrody.';

  @override
  String get treasureHuntSkippedScanUnavailable =>
      'Skanowanie QR-ów skarbu jest wyłączone, gdy gra terenowa jest pominięta.';

  @override
  String get treasureHuntSkippedCheckInUnavailable =>
      'Zameldowanie na wydarzeniu do gry jest wyłączone, gdy gra terenowa jest pominięta.';

  @override
  String get lockedTreasureScannedTitle => 'Ten punkt jest dalej na trasie';

  @override
  String get lockedTreasureScannedBody =>
      'Ten QR należy do punktu skarbowego, do którego jeszcze nie dotarłeś. Najpierw idź do aktualnie wyróżnionego punktu, a potem wróć tutaj.';

  @override
  String get focusNextPoint => 'Pokaż następny punkt';

  @override
  String get claimReward => 'Odbierz nagrodę';

  @override
  String get rewardClaimTitle => 'Odbierz nagrodę';

  @override
  String get rewardClaimBody =>
      'Pokaż ten kod QR osobie z Silver.NET. Zeskanuje go raz i oznaczy Twoją małą nagrodę jako odebraną.';

  @override
  String get rewardClaimReadyBody =>
      'Możesz już odebrać małą nagrodę. Pokaż QR nagrody osobie z Silver.NET.';

  @override
  String get rewardClaimEventRequiredBody =>
      'Już prawie gotowe. Zamelduj się na co najmniej jednym wydarzeniu skanerem QR w harmonogramie, aby odblokować QR nagrody.';

  @override
  String get rewardClaimEventRequiredAction => 'Zamelduj się na wydarzeniu';

  @override
  String get rewardAlreadyReceivedTitle => 'Nagroda została już odebrana';

  @override
  String get rewardAlreadyReceivedBody =>
      'Dla tego urządzenia organizator oznaczył już nagrodę jako odebraną.';

  @override
  String get rewardClaimDeviceId => 'ID urządzenia';

  @override
  String get rewardClaimPayloadHash => 'Kod weryfikacji';

  @override
  String get rewardClaimTreasureScans => 'Skany skarbów';

  @override
  String get rewardClaimEventCheckIns => 'Zameldowania na wydarzeniach';

  @override
  String get rewardClaimCompletedAt => 'Ukończono';

  @override
  String get eventRemindersSettingTitle => 'Przypomnienia o wydarzeniach';

  @override
  String get eventRemindersSettingDesc =>
      'Powiadom mnie 15 minut przed ulubionymi wydarzeniami z harmonogramu.';

  @override
  String get eventTags => 'Tagi';

  @override
  String get eventRemindersUnsupportedDesc => 'Tylko w aplikacji mobilnej.';

  @override
  String get eventRemindersEnabledSnack =>
      'Przypomnienia dla ulubionych wydarzeń są włączone.';

  @override
  String get pushNotificationsSettingTitle => 'Powiadomienia organizatorów';

  @override
  String get pushNotificationsSettingDesc =>
      'Otrzymuj ważne komunikaty wysyłane przez organizatorów wydarzenia.';

  @override
  String get pushNotificationsEnabledSnack =>
      'Powiadomienia organizatorów są włączone.';

  @override
  String get notificationsDefaultsEnabledSnack =>
      'Powiadomienia organizatorów i przypomnienia o wydarzeniach są włączone.';

  @override
  String favoriteEventReminderScheduledSnack(String eventTitle, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '# minuty',
      many: '# minut',
      few: '# minuty',
      one: '# minutę',
    );
    return 'O wydarzeniu $eventTitle dostaniesz powiadomienie za $_temp0.';
  }

  @override
  String get notificationPermissionDenied =>
      'Nie przyznano uprawnienia do powiadomień.';

  @override
  String get adminPreviewEventNotification => 'Podejrzyj powiadomienie';

  @override
  String get adminPreviewEventNotificationUnsupported =>
      'Podgląd lokalnego powiadomienia nie jest dostępny na tej platformie.';

  @override
  String get adminPreviewEventNotificationShown =>
      'Podgląd powiadomienia został wysłany na to urządzenie.';

  @override
  String get adminPreviewEventNotificationPermissionRequired =>
      'Do podglądu na tym urządzeniu potrzebne jest uprawnienie do powiadomień.';

  @override
  String get adminPreviewEventNotificationFailed =>
      'Nie udało się wyświetlić podglądu powiadomienia';

  @override
  String get permissionDeniedTitle => 'Potrzebujemy jeszcze jednej rzeczy';

  @override
  String get permissionDeniedCameraBody =>
      'Kamera pozwala skanować QR-y podczas gry po kampusie.';

  @override
  String get permissionDeniedLocationBody =>
      'Lokalizacja potwierdza, że jesteś wystarczająco blisko punktu.';

  @override
  String get permissionDeniedOpenSettings => 'Otwórz ustawienia';

  @override
  String get permissionDeniedRetry => 'Spróbuj ponownie';

  @override
  String get cameraLoading => 'Uruchamianie kamery...';
}
