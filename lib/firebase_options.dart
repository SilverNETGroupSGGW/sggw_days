import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for the `sggw-days` project.
///
/// Fill in the placeholder values from Firebase Console → Project Settings → Your apps.
/// Web: Add a web app in Firebase Console to get apiKey, appId, messagingSenderId.
/// Android: Download google-services.json to android/app/.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Fill in from Firebase Console → Project Settings → Web app
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'sggw-days',
    authDomain: 'sggw-days.firebaseapp.com',
    storageBucket: 'sggw-days.firebasestorage.app',
  );

  // TODO: Fill in from Firebase Console → Project Settings → Android app
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'sggw-days',
    storageBucket: 'sggw-days.firebasestorage.app',
  );

  // TODO: Fill in from Firebase Console → Project Settings → iOS app
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'sggw-days',
    storageBucket: 'sggw-days.firebasestorage.app',
    iosBundleId: 'com.example.sggwDays',
  );
}
