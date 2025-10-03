part of 'group_membership_read_bloc.dart';

class GroupMembershipReadState extends Equatable implements ErrorState {
  final String? groupId;
  final GroupMembershipState? groupMembershipState;
  final bool isLoading;
  final String? error;

  const GroupMembershipReadState(
    this.groupId, {
    this.groupMembershipState,
    this.isLoading = false,
    this.error,
  });

  GroupMembershipReadState copyWith({
    GroupMembershipState? groupMembershipState,
    bool clearGroupMembershipState = false,
    bool? isLoading,
    String? error,
  }) =>
      GroupMembershipReadState(
        this.groupId,
        groupMembershipState: clearGroupMembershipState
            ? null
            : (groupMembershipState ?? this.groupMembershipState),
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        groupId,
        groupMembershipState,
        isLoading,
        error,
      ];
}
