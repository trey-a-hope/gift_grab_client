part of 'user_read_bloc.dart';

class UserReadState extends Equatable implements ErrorState {
  final User? user;
  final bool isMyProfile;
  final bool isLoading;
  final String? error;

  const UserReadState({
    this.user,
    this.isMyProfile = false,
    this.isLoading = false,
    this.error,
  });

  UserReadState copyWith({
    User? user,
    bool? isMyProfile,
    bool? isLoading,
    String? error,
  }) =>
      UserReadState(
        user: user ?? this.user,
        isMyProfile: isMyProfile ?? this.isMyProfile,
        isLoading: isLoading == true ? true : false,
        error: error,
      );

  @override
  List<Object?> get props => [
        user,
        isMyProfile,
        isLoading,
        error,
      ];
}
