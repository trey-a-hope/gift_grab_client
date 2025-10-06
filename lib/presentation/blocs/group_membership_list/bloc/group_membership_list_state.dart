part of 'group_membership_list_bloc.dart';

class GroupMembershipListState extends Equatable implements ErrorState {
  final List<GroupUser> groupUsers;
  final bool isLoading;
  final String? error;

  const GroupMembershipListState({
    this.groupUsers = const [],
    this.isLoading = false,
    this.error,
  });

  GroupMembershipListState copyWith({
    List<GroupUser>? groupUsers,
    bool? isLoading,
    String? error,
  }) =>
      GroupMembershipListState(
        groupUsers: groupUsers ?? this.groupUsers,
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        groupUsers,
        isLoading,
        error,
      ];
}
