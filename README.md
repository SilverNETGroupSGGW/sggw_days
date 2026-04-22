# sggw_days

A new Flutter project.

## GitHub Actions Deployment

The repository deploys Firebase automatically with GitHub Actions:

- Pull requests run [firebase-hosting-pull-request.yml](.github/workflows/firebase-hosting-pull-request.yml) to validate the project, build a debug Android APK artifact, and create Hosting preview channels for branches in this repository.
- Pushes to `main` and manual workflow dispatch run [firebase-hosting-merge.yml](.github/workflows/firebase-hosting-merge.yml), which validates the Flutter project, builds the web app, and deploys Firebase Hosting plus Firestore and Storage rules to the `sggw-days` project.
- Pushes to `main` and manual workflow dispatch can also run [play-store-deploy.yml](.github/workflows/play-store-deploy.yml) to build an Android App Bundle and upload it to a Google Play closed testing track.

Required repository secret:

- `FIREBASE_SERVICE_ACCOUNT_SGGW_DAYS`: JSON for a Firebase service account with permission to deploy Hosting and update Firestore and Storage rules.

Additional secrets required by the Google Play workflow:

- `KEYSTORE_BASE64`: Base64-encoded Android upload keystore.
- `KEYSTORE_ALIAS`: Upload key alias.
- `KEYSTORE_PASSWORD`: Keystore password.
- `KEYSTORE_ALIAS_PASSWORD`: Upload key password.

Additional configuration required by the Google Play workflow:

- `GOOGLE_PLAY_CLOSED_TRACK`: The workflow currently defaults this to `alpha` at the top of [play-store-deploy.yml](.github/workflows/play-store-deploy.yml). Change it there if you want a different testing track.
- Manual runs can override the workflow default with the `play_track` workflow input.
- Release notes are generated automatically from commit subjects and uploaded through the Play release-notes mechanism as `whatsnew-en-US`.
- Manual runs can also override the default commit range with the `commit_range` workflow input. On pushes to `main`, the workflow uses the pushed commit range automatically.

Google Play upload prerequisite:

- The Android release bundle includes `android.permission.CAMERA` for QR scanning. Before [play-store-deploy.yml](.github/workflows/play-store-deploy.yml) can upload successfully, the app's Play Console listing must have a public privacy policy URL configured in App content. Use `https://sggw-days.web.app/privacy-policy`. Without that, Google Play rejects the upload with an error like `The apk has permissions that require a privacy policy set for the app`.

Storage rules are deployed through the explicit Firebase Storage target `main`, mapped in [.firebaserc](.firebaserc) to the bucket `sggw-days.firebasestorage.app`. The service account behind `FIREBASE_SERVICE_ACCOUNT_SGGW_DAYS` also needs Firebase Security Rules permissions including `firebaserules.rulesets.test` for the Firebase CLI deploy path.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
