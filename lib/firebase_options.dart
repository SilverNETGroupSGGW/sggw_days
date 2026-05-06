import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for the `sggw-days` project.
///
/// Generated Firebase configuration for each supported platform.
class DefaultFirebaseOptions {
  static const _iosApiKeyOverride = String.fromEnvironment('IOS_FIREBASE_API_KEY');
  static const _iosAppIdOverride = String.fromEnvironment('IOS_FIREBASE_APP_ID');
  static const _iosMessagingSenderIdOverride = String.fromEnvironment(
    'IOS_FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _iosProjectIdOverride = String.fromEnvironment('IOS_FIREBASE_PROJECT_ID');
  static const _iosStorageBucketOverride = String.fromEnvironment(
    'IOS_FIREBASE_STORAGE_BUCKET',
  );
  static const _iosClientIdOverride = String.fromEnvironment('IOS_FIREBASE_CLIENT_ID');
  static const _iosBundleIdOverride = String.fromEnvironment('IOS_FIREBASE_BUNDLE_ID');

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA86AiKYmy94rm0Sm_0I5Q0kMnqRr4i_ek',
    appId: '1:583939995714:web:64bb87337df191160755db',
    messagingSenderId: '583939995714',
    projectId: 'sggw-days',
    authDomain: 'sggw-days.firebaseapp.com',
    storageBucket: 'sggw-days.firebasestorage.app',
    measurementId: 'G-GX7TTYCPRG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCbzOts0v_Y_kZc7ZBRk1FvkwGFJUkgF50',
    appId: '1:583939995714:android:7d3fc1983787b0610755db',
    messagingSenderId: '583939995714',
    projectId: 'sggw-days',
    storageBucket: 'sggw-days.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _iosApiKeyOverride != ''
      ? _iosApiKeyOverride
      : 'AIzaSyCisIDKK2e5gOv9qPhTlXOqxMMaecXQfIQ',
    appId: _iosAppIdOverride != ''
      ? _iosAppIdOverride
      : '1:583939995714:ios:4e932895299047780755db',
    messagingSenderId: _iosMessagingSenderIdOverride != ''
      ? _iosMessagingSenderIdOverride
      : '583939995714',
    projectId: _iosProjectIdOverride != ''
      ? _iosProjectIdOverride
      : 'sggw-days',
    storageBucket: _iosStorageBucketOverride != ''
      ? _iosStorageBucketOverride
      : 'sggw-days.firebasestorage.app',
    iosClientId: _iosClientIdOverride != ''
      ? _iosClientIdOverride
      : '583939995714-79ch2uvg3patcbs256bv0512nmarqdcp.apps.googleusercontent.com',
    iosBundleId: _iosBundleIdOverride != ''
      ? _iosBundleIdOverride
      : 'com.silvernet.sggwDays',
  );
}
