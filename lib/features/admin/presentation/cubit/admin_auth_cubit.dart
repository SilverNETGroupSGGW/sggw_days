import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sggw_days/core/google_sign_in_config.dart';

part 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminAuthCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(const AdminAuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _finishAdminSignIn(user, emitLoading: false);
  }

  Future<void> loginWithGoogle() async {
    emit(
      state.copyWith(isLoading: true, isUnauthorized: false, clearError: true),
    );
    try {
      final UserCredential userCred;
      if (kIsWeb) {
        userCred = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        await GoogleSignInConfig.ensureInitialized();
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final idToken = googleAuth.idToken;
        if (idToken == null || idToken.isEmpty) {
          throw Exception('Google Sign-In did not return an ID token');
        }
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        userCred = await _auth.signInWithCredential(credential);
      }

      await _finishAdminSignIn(userCred.user);
    } catch (e, stackTrace) {
      if (_isGoogleSignInCancellation(e)) {
        debugPrint('Google admin sign-in cancelled.');
      } else {
        debugPrint('Google admin sign-in failed: $e\n$stackTrace');
      }
      await _auth.signOut();
      emit(state.copyWith(isLoading: false, error: _friendlyAuthMessage(e)));
    }
  }

  Future<void> loginWithEmailDebug(String email, String password) async {
    if (!kDebugMode) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Email login is available only in debug builds.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(isLoading: true, isUnauthorized: false, clearError: true),
    );
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _finishAdminSignIn(userCred.user);
    } catch (e, stackTrace) {
      debugPrint('Debug email admin sign-in failed: $e\n$stackTrace');
      await _auth.signOut();
      emit(state.copyWith(isLoading: false, error: _friendlyAuthMessage(e)));
    }
  }

  Future<void> _finishAdminSignIn(User? user, {bool emitLoading = true}) async {
    final uid = user?.uid;
    if (uid == null) {
      throw Exception('No UID after sign-in');
    }

    final doc = await _firestore.collection('admins').doc(uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      if (emitLoading) {
        emit(
          state.copyWith(
            isLoading: false,
            isUnauthorized: true,
            clearError: true,
          ),
        );
      }
      return;
    }

    emit(
      state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        isUnauthorized: false,
        clearError: true,
      ),
    );
  }

  String _friendlyAuthMessage(Object error) {
    if (_isGoogleSignInCancellation(error)) {
      return 'Sign-in was cancelled.';
    }
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'popup-closed-by-user' => 'Sign-in was cancelled.',
        'network-request-failed' => 'Network connection failed during sign-in.',
        'invalid-credential' => 'The sign-in credential was rejected.',
        'user-disabled' => 'This account is disabled.',
        'user-not-found' => 'No account exists for this email address.',
        'wrong-password' ||
        'invalid-login-credentials' => 'The email or password is incorrect.',
        _ => error.message ?? 'Firebase Authentication rejected sign-in.',
      };
    }

    final text = error.toString();
    if (text.contains('ID token')) {
      return 'Google did not return an ID token for this app configuration.';
    }
    return text.replaceFirst('Exception: ', '');
  }

  bool _isGoogleSignInCancellation(Object error) {
    return error is GoogleSignInException &&
        error.code == GoogleSignInExceptionCode.canceled;
  }

  Future<void> logout() async {
    if (!kIsWeb) {
      await GoogleSignInConfig.ensureInitialized();
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
    emit(const AdminAuthState());
  }
}
