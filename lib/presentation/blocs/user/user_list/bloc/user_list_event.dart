part of 'user_list_bloc.dart';

sealed class UserListEvent extends Equatable {
  const UserListEvent();
}

class SearchUser extends UserListEvent {
  final String username;

  const SearchUser(this.username);

  @override
  List<Object?> get props => [username];
}

class ClearSearch extends UserListEvent {
  const ClearSearch();

  @override
  List<Object?> get props => [];
}
