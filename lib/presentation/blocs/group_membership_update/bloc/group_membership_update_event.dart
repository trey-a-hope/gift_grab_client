part of 'group_membership_update_bloc.dart';

sealed class GroupMembershipUpdateEvent extends Equatable {
  const GroupMembershipUpdateEvent();
}

class JoinGroup extends GroupMembershipUpdateEvent {
  const JoinGroup();

  @override
  List<Object?> get props => [];
}

class LeaveGroup extends GroupMembershipUpdateEvent {
  const LeaveGroup();

  @override
  List<Object?> get props => [];
}

class CancelRequest extends GroupMembershipUpdateEvent {
  const CancelRequest();

  @override
  List<Object?> get props => [];
}

class AddGroupUsers extends GroupMembershipUpdateEvent {
  final List<String> uids;

  const AddGroupUsers(this.uids);

  @override
  List<Object?> get props => [uids];
}
