part of 'record_delete_bloc.dart';

sealed class RecordDeleteEvent extends Equatable {
  const RecordDeleteEvent();
}

class DeleteRecord extends RecordDeleteEvent {
  const DeleteRecord();

  @override
  List<Object?> get props => [];
}
