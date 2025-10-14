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

class AcceptRequest extends GroupMembershipUpdateEvent {
  final String uid;

  const AcceptRequest(this.uid);

  @override
  List<Object?> get props => [uid];
}

class KickUser extends GroupMembershipUpdateEvent {
  final String uid;

  const KickUser(this.uid);

  @override
  List<Object?> get props => [uid];
}

class DenyRequest extends GroupMembershipUpdateEvent {
  final String uid;

  const DenyRequest(this.uid);

  @override
  List<Object?> get props => [uid];
}

class PromoteUser extends GroupMembershipUpdateEvent {
  final String uid;

  const PromoteUser(this.uid);

  @override
  List<Object?> get props => [uid];
}

class DemoteUser extends GroupMembershipUpdateEvent {
  final String uid;

  const DemoteUser(this.uid);

  @override
  List<Object?> get props => [uid];
}

class BanUser extends GroupMembershipUpdateEvent {
  final String uid;

  const BanUser(this.uid);

  @override
  List<Object?> get props => [uid];
}
