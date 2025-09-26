part of 'group_list_bloc.dart';

sealed class GroupListEvent extends Equatable {
  const GroupListEvent();
}

class InitialFetch extends GroupListEvent {
  const InitialFetch();
  @override
  List<Object?> get props => [];
}

class FetchMore extends GroupListEvent {
  const FetchMore();
  @override
  List<Object?> get props => [];
}

class FetchGroups extends GroupListEvent {
  const FetchGroups();
  @override
  List<Object?> get props => [];
}

class SearchGroup extends GroupListEvent {
  final String name;

  const SearchGroup(this.name);

  @override
  List<Object?> get props => [name];
}

class ClearSearch extends GroupListEvent {
  const ClearSearch();

  @override
  List<Object?> get props => [];
}
