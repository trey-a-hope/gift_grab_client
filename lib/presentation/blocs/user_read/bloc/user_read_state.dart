part of 'user_read_bloc.dart';

class UserReadState extends Equatable implements ErrorState {
  final User? user;
  final bool isMyProfile;
  final FriendshipState? friendshipState;
  final bool isLoading;
  final String? error;

  const UserReadState({
    this.user,
    this.isMyProfile = false,
    this.friendshipState,
    this.isLoading = false,
    this.error,
  });

  UserReadState copyWith({
    User? user,
    bool? isMyProfile,
    FriendshipState? friendshipState,
    bool clearFriendshipState = false,
    bool? isLoading,
    String? error,
  }) =>
      UserReadState(
        user: user ?? this.user,
        isMyProfile: isMyProfile ?? this.isMyProfile,
        friendshipState: clearFriendshipState
            ? null
            : (friendshipState ?? this.friendshipState),
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        user,
        isMyProfile,
        friendshipState,
        isLoading,
        error,
      ];
}
