# sggw_days

A new Flutter project.

## Releases

Releases go through Infra's shared release workflow ([docs/releases.md](https://github.com/SilverNETGroupSGGW/Infra/blob/main/docs/releases.md)), called from [release.yml](.github/workflows/release.yml). Pushing a tag no longer publishes anything; publishing a GitHub release does.

- **Beta:** publish a GitHub release for a tag such as `1.2.4-beta.1` with "Set as a pre-release" ticked. The builds (per-ABI APKs, App Bundle, web zip) are attached to the release, Google Play gets the bundle on open testing, TestFlight gets the iOS build, and [firebase.yml](.github/workflows/firebase.yml) deploys the web build to the beta Hosting site.
- **Production:** untick "Set as a pre-release" on a tested pre-release, or publish a release without it. The same builds go to Google Play production and App Review, and `firebase.yml` deploys the web build to the live Hosting site together with Cloud Functions and the Firestore and Storage rules from the release's tag.
- **Versions:** the next release is 1.2.4 or higher, since 1.2.3 was the last one on the old workflows. The tag sets the version; `pubspec.yaml`'s version is only used by local builds.
- **Publishing again:** run `Release` by hand from the release's tag to send its store builds to a track again without rebuilding.
- **Signing:** the upload key stays in the `KEYSTORE_BASE64`, `KEYSTORE_ALIAS`, `KEYSTORE_PASSWORD` and `KEYSTORE_ALIAS_PASSWORD` secrets; `release.yml` passes them to the shared workflow under its own names. Local release builds without the key fall back to the debug key.
- **Store IDs:** `com.silvernet.sggw_days` and `com.silver.sggw-days` are set in this app's entry in Infra's `apps.yaml`.

The build commands are mise tasks in [mise.toml](mise.toml), the same ones the release runs: `mise run build:apk`, `mise run build:appbundle` and `mise run build:web`.

### Firebase deploys

[firebase.yml](.github/workflows/firebase.yml) runs after every successful `Release` run of a published release and deploys that release's web build. It signs in to Google Cloud without a key, through Workload Identity Federation (provider `sggw-days-firebase`), which only accepts this workflow on `main`. To redeploy a release by hand, run `Firebase` from `main` with the release's tag and the target: `beta` deploys only `hosting:beta`, `live` deploys `hosting:live,functions,firestore:rules,storage:main`.

Hosting deploys only after the whole `Release` run succeeds, store jobs included, so a failed store job also stops the Hosting deploy; run `Firebase` by hand then.

The Firebase Hosting configuration in [firebase.json](firebase.json) now uses explicit deploy targets: `hosting:beta` maps to `beta-sggw-days`, and `hosting:live` maps to `sggw-days`. This keeps workflow names and deploy commands aligned with the actual site roles.

The beta Hosting site is not a separate Firebase environment. It shares the same Firebase project resources as the live site, so a pre-release deploys only Hosting content to beta; Functions and rules change only with a production release.

The live deploy includes Cloud Functions for the admin broadcast notification sender. Broadcast requests are created from the admin panel, then `functions/index.js` sends them to registered client tokens with the Firebase Admin SDK.

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

The `prepare_web_deploy.dart` step copies `web/.well-known` into `build/web/.well-known`; Flutter does not copy dot-directories there by default. `mise run build:web` runs it after the web build, so the release's web zip already contains these files.

iOS verifies the same domain with an Apple App Site Association file served from both `https://sggw-days.web.app/apple-app-site-association` and `https://sggw-days.web.app/.well-known/apple-app-site-association`.

`tool/prepare_web_deploy.dart` generates those files during web builds from:

- `APPLE_TEAM_ID`, read from [ios/Flutter/AppConfig.xcconfig](ios/Flutter/AppConfig.xcconfig) unless the environment sets it
- `IOS_BUNDLE_IDENTIFIER` or `APP_BUNDLE_IDENTIFIER` from the environment, else `APP_BUNDLE_IDENTIFIER` from the same file, else `com.silver.sggw-days`

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

Google Play upload prerequisite:

- The Android release bundle includes `android.permission.CAMERA` for QR scanning, so the app's Play Console listing must have a public privacy policy URL configured in App content: `https://sggw-days.web.app/privacy-policy`. Without it, Google Play rejects the upload with an error like `The apk has permissions that require a privacy policy set for the app`.

Storage rules are deployed through the explicit Firebase Storage target `main`, mapped in [.firebaserc](.firebaserc) to the bucket `sggw-days.firebasestorage.app`. The service account `firebase.yml` signs in as (`github-action-1132232110@sggw-days.iam.gserviceaccount.com`) needs permission to deploy Hosting, Cloud Functions and the Firestore and Storage rules, including `firebaserules.rulesets.test` for the Firebase CLI deploy path.

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
