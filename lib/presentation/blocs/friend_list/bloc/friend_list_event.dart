part of 'friend_list_bloc.dart';

sealed class FriendListEvent extends Equatable {
  const FriendListEvent();
}

class InitialFetch extends FriendListEvent {
  const InitialFetch();

  @override
  List<Object?> get props => [];
}

class FetchMore extends FriendListEvent {
  const FetchMore();

  @override
  List<Object?> get props => [];
}

class FetchFriends extends FriendListEvent {
  const FetchFriends();

  @override
  List<Object?> get props => [];
}
