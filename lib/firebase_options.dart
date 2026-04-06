import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for the `sggw-days` project.
///
/// Generated Firebase configuration for each supported platform.
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
    appId: '1:583939995714:android:6d7f39be62d3d0350755db',
    messagingSenderId: '583939995714',
    projectId: 'sggw-days',
    storageBucket: 'sggw-days.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCisIDKK2e5gOv9qPhTlXOqxMMaecXQfIQ',
    appId: '1:583939995714:ios:3a42cd195f20776b0755db',
    messagingSenderId: '583939995714',
    projectId: 'sggw-days',
    storageBucket: 'sggw-days.firebasestorage.app',
    iosBundleId: 'com.example.sggwDays',
  );
}
