import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';

part 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  // SHA-256 hash of the default admin password "sggw2025"
  static final String _passwordHash =
      sha256.convert(utf8.encode('sggw2025')).toString();

  AdminAuthCubit() : super(const AdminAuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final box = await Hive.openBox('admin_auth');
    final isAuthenticated =
        box.get('authenticated', defaultValue: false) as bool;
    emit(state.copyWith(isAuthenticated: isAuthenticated));
  }

  Future<bool> login(String password) async {
    final inputHash = sha256.convert(utf8.encode(password)).toString();
    if (inputHash == _passwordHash) {
      final box = await Hive.openBox('admin_auth');
      await box.put('authenticated', true);
      emit(state.copyWith(isAuthenticated: true));
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final box = await Hive.openBox('admin_auth');
    await box.put('authenticated', false);
    emit(state.copyWith(isAuthenticated: false));
  }
}
