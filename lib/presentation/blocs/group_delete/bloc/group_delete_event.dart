part of 'group_delete_bloc.dart';

sealed class GroupDeleteEvent extends Equatable {
  const GroupDeleteEvent();
}

class DeleteGroup extends GroupDeleteEvent {
  const DeleteGroup();
  @override
  List<Object?> get props => [];
}
