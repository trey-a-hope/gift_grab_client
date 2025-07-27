part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final bool authenticated;
  final String? error;

  const AuthState({
    this.authenticated = false,
    this.error,
  });

  AuthState copyWith({
    bool? authenticated,
    String? error,
  }) =>
      AuthState(
        authenticated: authenticated ?? this.authenticated,
        error: error,
      );

  @override
  List<Object?> get props => [authenticated, error];
}
