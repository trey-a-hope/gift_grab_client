part of 'user_list_bloc.dart';

class UserListState extends Equatable implements ErrorState {
  final String query;
  final List<User> users;
  final bool isLoading;
  final String? error;

  const UserListState({
    this.query = '',
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UserListState copyWith({
    String? query,
    List<User>? users,
    bool? isLoading,
    String? error,
  }) =>
      UserListState(
        query: query ?? this.query,
        users: users ?? this.users,
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        query,
        users,
        isLoading,
        error,
      ];
}
