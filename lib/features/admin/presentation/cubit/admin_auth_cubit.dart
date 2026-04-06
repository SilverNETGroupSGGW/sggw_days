import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  final FirebaseAuth _auth;

  AdminAuthCubit({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance,
      super(const AdminAuthState()) {
    _checkAuth();
  }

  void _checkAuth() {
    final user = _auth.currentUser;
    emit(state.copyWith(isAuthenticated: user != null));
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(state.copyWith(isAuthenticated: true));
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    emit(state.copyWith(isAuthenticated: false));
  }
}
