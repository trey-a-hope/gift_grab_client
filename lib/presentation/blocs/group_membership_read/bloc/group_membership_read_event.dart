part of 'group_membership_read_bloc.dart';

sealed class GroupMembershipReadEvent extends Equatable {
  const GroupMembershipReadEvent();
}

class ReadGroupMembership extends GroupMembershipReadEvent {
  const ReadGroupMembership();

  @override
  List<Object?> get props => [];
}
