import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInConfig {
  GoogleSignInConfig._();

  static Future<void>? _initialization;

  static Future<void> ensureInitialized() {
    if (kIsWeb) {
      return Future<void>.value();
    }

    return _initialization ??= GoogleSignIn.instance.initialize();
  }
}
