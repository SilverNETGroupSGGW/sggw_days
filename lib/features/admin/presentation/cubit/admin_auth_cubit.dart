import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    final doc = await _firestore.collection('admins').doc(user.uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      return;
    }
    emit(state.copyWith(isAuthenticated: true));
  }

  Future<void> loginWithGoogle() async {
    emit(state.copyWith(isLoading: true, isUnauthorized: false));
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

      final uid = userCred.user?.uid;
      if (uid == null) throw Exception('No UID after Google sign-in');

      final doc = await _firestore.collection('admins').doc(uid).get();
      if (!doc.exists) {
        await _auth.signOut();
        emit(state.copyWith(isLoading: false, isUnauthorized: true));
        return;
      }

      emit(state.copyWith(isLoading: false, isAuthenticated: true));
    } catch (e) {
      await _auth.signOut();
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
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
