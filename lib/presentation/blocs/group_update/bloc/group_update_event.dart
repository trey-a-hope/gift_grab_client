part of 'group_update_bloc.dart';

sealed class GroupUpdateEvent extends Equatable {
  const GroupUpdateEvent();
}

class InitForm extends GroupUpdateEvent {
  final Group group;

  const InitForm(this.group);

  @override
  List<Object?> get props => [group];
}

class NameChanged extends GroupUpdateEvent {
  final String val;
  const NameChanged(this.val);
  @override
  List<Object?> get props => [val];
}

class DescriptionChanged extends GroupUpdateEvent {
  final String val;
  const DescriptionChanged(this.val);
  @override
  List<Object?> get props => [val];
}

class OpenChanged extends GroupUpdateEvent {
  final bool val;
  const OpenChanged(this.val);
  @override
  List<Object?> get props => [val];
}

class SaveForm extends GroupUpdateEvent {
  final String groupId;
  const SaveForm(this.groupId);
  @override
  List<Object?> get props => [groupId];
}
