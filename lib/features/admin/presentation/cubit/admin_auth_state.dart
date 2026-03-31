part of 'admin_auth_cubit.dart';

class AdminAuthState extends Equatable {
  final bool isAuthenticated;

  const AdminAuthState({this.isAuthenticated = false});

  AdminAuthState copyWith({bool? isAuthenticated}) {
    return AdminAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [isAuthenticated];
}
