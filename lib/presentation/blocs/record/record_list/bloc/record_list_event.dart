part of 'record_list_bloc.dart';

sealed class RecordListEvent extends Equatable {
  const RecordListEvent();
}

class FetchRecords extends RecordListEvent {
  final bool reset;

  const FetchRecords({required this.reset});

  @override
  List<Object?> get props => [reset];
}
