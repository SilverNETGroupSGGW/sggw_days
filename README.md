# sggw_days

A new Flutter project.

## GitHub Actions Deployment

The repository deploys Firebase automatically with GitHub Actions:

- Pull requests run [firebase-hosting-pull-request.yml](.github/workflows/firebase-hosting-pull-request.yml) to validate the project, build a debug Android APK artifact, and create Hosting preview channels for branches in this repository.
- Pushes to `main` and manual workflow dispatch run [firebase-hosting-merge.yml](.github/workflows/firebase-hosting-merge.yml), which validates the Flutter project, builds the web app, and deploys Firebase Hosting, Functions, plus Firestore and Storage rules to the `sggw-days` project.
- Pushes to `main` and manual workflow dispatch can also run [play-store-deploy.yml](.github/workflows/play-store-deploy.yml) to build an Android App Bundle and upload it to Google Play. The workflow defaults to the public testing track and can be overridden for closed testing when needed.

Required repository secret:

- `FIREBASE_SERVICE_ACCOUNT_SGGW_DAYS`: JSON for a Firebase service account with permission to deploy Hosting and update Firestore and Storage rules.
- `FIREBASE_WEB_PUSH_VAPID_KEY`: Firebase Cloud Messaging web push certificate key used when building the web app. Without it, web clients cannot opt in to broadcast push notifications; Android and iOS push still use native FCM tokens.

The Firebase service account also needs permission to deploy Cloud Functions for the admin broadcast notification sender. Broadcast requests are created from the admin panel, then `functions/index.js` sends them to registered client tokens with the Firebase Admin SDK.

Firebase Authentication must have Anonymous sign-in enabled for public leaderboard publishing. The app uses anonymous Firebase user IDs to make sure each device can update only its own aggregate leaderboard score.

## Android App Links Verification

Android only marks `https://sggw-days.web.app/scan/...` links as verified when Firebase Hosting serves a Digital Asset Links file at `https://sggw-days.web.app/.well-known/assetlinks.json`.

The repository includes [web/.well-known/assetlinks.json](web/.well-known/assetlinks.json) with the dev-container debug signing fingerprint so debug installs built here can be verified after Hosting deployment. Before a production deploy, add the exact SHA-256 certificate fingerprint Android will see:

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
			"sha256_cert_fingerprints": [
				"AA:BB:CC:DD:...:99"
			]
		}
	}
]
```

After deployment, verify from a connected Android device with:

```bash
flutter build web --release
dart run tool/prepare_web_deploy.dart
adb shell pm get-app-links com.silvernet.sggw_days
adb shell pm verify-app-links --re-verify com.silvernet.sggw_days
```

The `prepare_web_deploy.dart` step copies `web/.well-known` into `build/web/.well-known`; Flutter does not copy dot-directories there by default. The Firebase Hosting workflows run this step automatically after web builds.

Additional secrets required by the Google Play workflow:

- `KEYSTORE_BASE64`: Base64-encoded Android upload keystore.
- `KEYSTORE_ALIAS`: Upload key alias.
- `KEYSTORE_PASSWORD`: Keystore password.
- `KEYSTORE_ALIAS_PASSWORD`: Upload key password.

Additional configuration required by the Google Play workflow:

- `GOOGLE_PLAY_DEFAULT_TRACK`: The workflow currently defaults this to `beta` at the top of [play-store-deploy.yml](.github/workflows/play-store-deploy.yml). `beta` is the Google Play open/public testing track. Override it with a custom track name if you want closed testing instead.
- `GOOGLE_PLAY_DEFAULT_STATUS`: The workflow currently defaults this to `completed`, so successful uploads are published to the target testing track without manual Play Console promotion.
- `GOOGLE_PLAY_BUILD_NUMBER_OFFSET`: The workflow generates a unique Android `versionCode` from the GitHub Actions run number and run attempt, plus this offset. Increase the offset if your Play Console already contains larger version codes.
- Manual runs can override the workflow defaults with the `play_track`, `release_status`, and `build_number` workflow inputs.
- Release notes are generated automatically from commit subjects and uploaded through the Play release-notes mechanism as `whatsnew-en-US`.
- Manual runs can also override the default commit range with the `commit_range` workflow input. On pushes to `main`, the workflow uses the pushed commit range automatically.

Flutter-specific versioning note:

- Flutter maps `pubspec.yaml` version metadata to Android `versionName` and `versionCode`. The workflow passes `--build-number` to `flutter build appbundle`, which is the Flutter-supported way to assign a unique Android `versionCode` in CI without manually editing `pubspec.yaml` for every release.

Google Play upload prerequisite:

- The Android release bundle includes `android.permission.CAMERA` for QR scanning. Before [play-store-deploy.yml](.github/workflows/play-store-deploy.yml) can upload successfully, the app's Play Console listing must have a public privacy policy URL configured in App content. Use `https://sggw-days.web.app/privacy-policy`. Without that, Google Play rejects the upload with an error like `The apk has permissions that require a privacy policy set for the app`.

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
