part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final bool authenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.authenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({bool? authenticated, bool? isLoading, String? error}) =>
      AuthState(
        authenticated: authenticated ?? this.authenticated,
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [authenticated, isLoading, error];
}
