# sggw_days

A new Flutter project.

## GitHub Actions Deployment

The repository deploys Firebase automatically with GitHub Actions:

- Pull requests run [firebase-hosting-pull-request.yml](.github/workflows/firebase-hosting-pull-request.yml) to validate the project, build a debug Android APK artifact, and create Hosting preview channels for branches in this repository.
- Pushes to `main` and manual workflow dispatch run [firebase-hosting-merge.yml](.github/workflows/firebase-hosting-merge.yml), which validates the Flutter project, builds the web app, and deploys Firebase Hosting plus Firestore and Storage rules to the `sggw-days` project.

Required repository secret:

- `FIREBASE_SERVICE_ACCOUNT_SGGW_DAYS`: JSON for a Firebase service account with permission to deploy Hosting and update Firestore and Storage rules.

Storage rules are deployed through the explicit Firebase Storage target `main`, mapped in [.firebaserc](.firebaserc) to the bucket `sggw-days.firebasestorage.app`. The service account behind `FIREBASE_SERVICE_ACCOUNT_SGGW_DAYS` also needs Firebase Security Rules permissions including `firebaserules.rulesets.test` for the Firebase CLI deploy path.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
