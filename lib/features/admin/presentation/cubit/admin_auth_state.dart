part of 'admin_auth_cubit.dart';

class AdminAuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isUnauthorized;
  final String? error;

  const AdminAuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isUnauthorized = false,
    this.error,
  });

  AdminAuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isUnauthorized,
    String? error,
    bool clearError = false,
  }) {
    return AdminAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    isAuthenticated,
    isLoading,
    isUnauthorized,
    error,
  ];
}
