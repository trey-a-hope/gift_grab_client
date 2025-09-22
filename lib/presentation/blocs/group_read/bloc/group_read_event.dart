part of 'group_read_bloc.dart';

sealed class GroupReadEvent extends Equatable {
  const GroupReadEvent();
}

class ReadGroup extends GroupReadEvent {
  const ReadGroup();
  @override
  List<Object?> get props => [];
}
