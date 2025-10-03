part of 'group_membership_read_bloc.dart';

sealed class GroupMembershipReadEvent extends Equatable {
  const GroupMembershipReadEvent();
}

class ReadGroupMembershipState extends GroupMembershipReadEvent {
  const ReadGroupMembershipState();

  @override
  List<Object?> get props => [];
}
