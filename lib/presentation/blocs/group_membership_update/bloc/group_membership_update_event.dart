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

class AddGroupUser extends GroupMembershipUpdateEvent {
  final String uid;

  const AddGroupUser(this.uid);

  @override
  List<Object?> get props => [uid];
}

class KickGroupUser extends GroupMembershipUpdateEvent {
  final String uid;

  const KickGroupUser(this.uid);

  @override
  List<Object?> get props => [uid];
}

class DenyRequest extends GroupMembershipUpdateEvent {
  final String uid;

  const DenyRequest(this.uid);

  @override
  List<Object?> get props => [uid];
}
