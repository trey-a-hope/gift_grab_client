part of 'group_list_bloc.dart';

class GroupListState extends Equatable implements ErrorState {
  final String? uid;
  final String query;
  final List<Group> groups;
  final String? cursor;
  final bool isLoading;
  final String? error;

  const GroupListState({
    this.uid,
    this.query = '',
    this.groups = const [],
    this.cursor,
    this.isLoading = false,
    this.error,
  });

  GroupListState copyWith({
    String? uid,
    String? query,
    List<Group>? groups,
    String? cursor,
    bool clearCursor = false,
    bool? isLoading,
    String? error,
  }) =>
      GroupListState(
        uid: uid ?? this.uid,
        query: query ?? this.query,
        groups: groups ?? this.groups,
        cursor: clearCursor ? null : (cursor ?? this.cursor),
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        uid,
        query,
        groups,
        cursor,
        isLoading,
        error,
      ];
}
