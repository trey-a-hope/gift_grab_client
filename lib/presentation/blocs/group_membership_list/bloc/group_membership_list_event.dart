part of 'group_membership_list_bloc.dart';

sealed class GroupMembershipListEvent extends Equatable {
  const GroupMembershipListEvent();
}

class FetchUsers extends GroupMembershipListEvent {
  const FetchUsers();

  @override
  List<Object?> get props => [];
}
