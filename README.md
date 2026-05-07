# sggw_days

A new Flutter project.

## GitHub Actions Deployment

The repository deploys Firebase automatically with GitHub Actions:

- Pull requests run [firebase-hosting-pull-request.yml](.github/workflows/firebase-hosting-pull-request.yml) to validate the project, build a debug Android APK artifact, and create Hosting preview channels for branches in this repository.
- Pushes to `main` and manual workflow dispatch run [firebase-hosting-merge.yml](.github/workflows/firebase-hosting-merge.yml), which validates the Flutter project, builds the web app, and deploys Firebase Hosting, Functions, plus Firestore and Storage rules to the `sggw-days` project.
- Semver tags such as `v1.2.3` automatically run [store-release.yml](.github/workflows/store-release.yml), which validates the repo once and then fans out to the reusable [ios-store.yml](.github/workflows/ios-store.yml) and [android-store.yml](.github/workflows/android-store.yml) workflows in their testing modes.
- Published GitHub Releases from semver tags automatically run [store-release.yml](.github/workflows/store-release.yml), which fans out to [ios-store.yml](.github/workflows/ios-store.yml) in `app_store` mode and [android-store.yml](.github/workflows/android-store.yml) in `production` mode. The iOS workflow submits the already-uploaded TestFlight build for review, and the Android workflow promotes the already-uploaded testing release to the configured production track.

Required repository secret:

- `FIREBASE_SERVICE_ACCOUNT_SGGW_DAYS`: JSON for a Firebase service account with permission to deploy Hosting and update Firestore and Storage rules.

The Firebase service account also needs permission to deploy Cloud Functions for the admin broadcast notification sender. Broadcast requests are created from the admin panel, then `functions/index.js` sends them to registered client tokens with the Firebase Admin SDK.

The web push VAPID public key is baked into [lib/features/notifications/data/notification_repository.dart](lib/features/notifications/data/notification_repository.dart), so Hosting builds do not need a separate GitHub secret or variable for it. It can still be overridden with the `FIREBASE_WEB_PUSH_VAPID_KEY` Dart define if the Firebase web push key pair changes in the future.

## Verified App Links

The app claims `https://sggw-days.web.app/scan/...` on both Android and iOS so the OS can open the app directly instead of showing the browser chooser.

Android verifies the domain with Digital Asset Links at `https://sggw-days.web.app/.well-known/assetlinks.json`.

The repository keeps [web/.well-known/assetlinks.json](web/.well-known/assetlinks.json) with the current fingerprints used by this project:

- local debug builds in this dev container,
- Google Play installs signed by Google Play App Signing,
- direct installs signed with the current upload key.

That is enough for the current setup without any extra Android Hosting variable. If signing changes in the future, update [web/.well-known/assetlinks.json](web/.well-known/assetlinks.json) directly.

Add every production fingerprint Android can see there:

- Google Play installs: use Play Console → Setup → App signing → App signing key certificate → SHA-256 certificate fingerprint.
- Local debug installs: `keytool -list -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey`.
- Direct release APK/AAB installs outside Play: use the release signing certificate fingerprint for that build.

The file should look like this, with every real fingerprint value in the array:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.silvernet.sggw_days",
      "sha256_cert_fingerprints": ["AA:BB:CC:DD:...:99"]
    }
  }
]
```

After deployment, verify from a connected Android device with:

```bash
flutter build web --release --no-tree-shake-icons
dart run tool/prepare_web_deploy.dart
adb shell pm get-app-links com.silvernet.sggw_days
adb shell pm verify-app-links --re-verify com.silvernet.sggw_days
```

The `prepare_web_deploy.dart` step copies `web/.well-known` into `build/web/.well-known`; Flutter does not copy dot-directories there by default. The Firebase Hosting workflows run this step automatically after web builds.

iOS verifies the same domain with an Apple App Site Association file served from both `https://sggw-days.web.app/apple-app-site-association` and `https://sggw-days.web.app/.well-known/apple-app-site-association`.

`tool/prepare_web_deploy.dart` now generates those files automatically during Hosting builds from:

- `APPLE_TEAM_ID`
- `IOS_BUNDLE_IDENTIFIER` (falls back to `com.silver.sggw-days` when the repo variable is not set)

The generated association currently claims only the in-app scan route:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.silver.sggw-days",
        "paths": ["/scan/*"]
      }
    ]
  }
}
```

Additional secrets required by the Google Play workflow:

- `KEYSTORE_BASE64`: Base64-encoded Android upload keystore.
- `KEYSTORE_ALIAS`: Upload key alias.
- `KEYSTORE_PASSWORD`: Keystore password.
- `KEYSTORE_ALIAS_PASSWORD`: Upload key password.

Additional configuration required by the Google Play workflow:

- `GOOGLE_PLAY_PACKAGE_NAME`: Android application id used for Play uploads. Set this to `com.silvernet.sggw_days` for the current app.
- `GOOGLE_PLAY_TESTING_TRACK`: Testing track used by [android-store.yml](.github/workflows/android-store.yml) when `target=testing`. The default is `beta`, which maps to Google Play open testing.
- `GOOGLE_PLAY_TESTING_STATUS`: Release status used for testing uploads. The default is `completed`.
- `GOOGLE_PLAY_PRODUCTION_TRACK`: Production track used by [android-store.yml](.github/workflows/android-store.yml) when `target=production`. The default is `production`.
- `GOOGLE_PLAY_PRODUCTION_STATUS`: Release status used when promoting the testing release into production. The default is `completed`.
- `GOOGLE_PLAY_BUILD_NUMBER_OFFSET`: Manual builds without a semver release version still fall back to a unique Android `versionCode` based on the GitHub Actions run number and this offset.
- Store tags must be strict semver (`v1.2.3` or `1.2.3`). The workflows derive deterministic testing and production build numbers from that version.
- Manual Android runs use `target` to choose `testing` or `production`, then can override defaults with `release_version`, `play_track`, `release_status`, `build_number`, and `commit_range` as needed.
- Production Play release notes are taken from the GitHub Release body. Testing release notes are generated automatically from commit subjects since the previous tag. Both paths normalize and truncate the final `en-US` note to Google Play's 500-character limit before upload.

Additional configuration required by the iOS store workflows:

- `APPSTORE_API_PRIVATE_KEY` is always required for App Store Connect API access.
- `APPLE_TEAM_ID` is also reused by the Hosting deploy to generate the Apple App Site Association file for universal links.
- `MATCH_PASSWORD` enables the preferred fastlane `match` signing path, using the private repo as encrypted signing storage on the `match-signing` branch by default.
- When [ios-store.yml](.github/workflows/ios-store.yml) runs with `target=testflight`, it falls back to the existing direct-signing secrets if `MATCH_PASSWORD` is not present yet: `APPSTORE_CERTIFICATES_FILE_BASE64`, `APPSTORE_CERTIFICATES_PASSWORD`, and `IOS_APPSTORE_PROFILE_BASE64`.
- When [ios-store.yml](.github/workflows/ios-store.yml) runs with `target=app_store`, it does not rebuild the app. It submits the exact build number that was already uploaded from the matching tag.
- Manual iOS runs use `target` to choose `testflight` or `app_store`, and can override `release_version`, `build_number`, `commit_range`, `wait_for_processing`, or `automatic_release` when appropriate.

Flutter-specific versioning note:

- Flutter maps `pubspec.yaml` version metadata to Android `versionName` and `versionCode`, and iOS `CFBundleShortVersionString` and `CFBundleVersion`. The store workflows pass `--build-name` and `--build-number` so tags such as `v1.2.3` produce the correct store version without editing `pubspec.yaml` for every release.

Google Play upload prerequisite:

- The Android release bundle includes `android.permission.CAMERA` for QR scanning. Before [android-store.yml](.github/workflows/android-store.yml) can upload successfully in `target=testing`, the app's Play Console listing must have a public privacy policy URL configured in App content. Use `https://sggw-days.web.app/privacy-policy`. Without that, Google Play rejects the upload with an error like `The apk has permissions that require a privacy policy set for the app`.

Storage rules are deployed through the explicit Firebase Storage target `main`, mapped in [.firebaserc](.firebaserc) to the bucket `sggw-days.firebasestorage.app`. The service account behind `FIREBASE_SERVICE_ACCOUNT_SGGW_DAYS` also needs Firebase Security Rules permissions including `firebaserules.rulesets.test` for the Firebase CLI deploy path.

## App Icon Validation

The launcher icon source of truth is [assets/icon/source/app_icon.svg](assets/icon/source/app_icon.svg). Regenerate and validate production icon assets with:

```bash
dart run tool/generate_app_icons.dart
dart run flutter_launcher_icons
dart run tool/validate_android_icons.dart
```

The validator checks the source SVG alignment group, generated 1024px icon sources, Android adaptive icon XML, monochrome/foreground layers, and density-specific launcher resources. CI runs the same validation and fails if generated icon files are out of date.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
