part of 'friend_list_bloc.dart';

class FriendListState extends Equatable implements ErrorState {
  final FriendshipState friendshipState;
  final List<Friend> friends;
  final String? cursor;
  final bool isLoading;
  final String? error;

  const FriendListState(
    this.friendshipState, {
    this.friends = const [],
    this.cursor,
    this.isLoading = false,
    this.error,
  });

  FriendListState copyWith({
    List<Friend>? friends,
    String? cursor,
    bool? isLoading,
    String? error,
  }) =>
      FriendListState(
        this.friendshipState,
        friends: friends ?? this.friends,
        cursor: cursor,
        isLoading: isLoading == true ? true : false,
        error: error,
      );

  @override
  List<Object?> get props => [
        friendshipState,
        friends,
        cursor,
        isLoading,
        error,
      ];
}
