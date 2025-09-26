part of 'group_create_bloc.dart';

sealed class GroupCreateEvent extends Equatable {
  const GroupCreateEvent();
}

class NameChanged extends GroupCreateEvent {
  final String val;
  const NameChanged(this.val);
  @override
  List<Object?> get props => [val];
}

class DescriptionChanged extends GroupCreateEvent {
  final String val;
  const DescriptionChanged(this.val);
  @override
  List<Object?> get props => [val];
}

class MaxCountChanged extends GroupCreateEvent {
  final int val;
  const MaxCountChanged(this.val);
  @override
  List<Object?> get props => [val];
}

class OpenChanged extends GroupCreateEvent {
  final bool val;
  const OpenChanged(this.val);
  @override
  List<Object?> get props => [val];
}

class SaveForm extends GroupCreateEvent {
  const SaveForm();
  @override
  List<Object?> get props => [];
}
