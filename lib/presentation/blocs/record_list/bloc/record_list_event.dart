part of 'record_list_bloc.dart';

sealed class RecordListEvent extends Equatable {
  const RecordListEvent();
}

class InitialFetch extends RecordListEvent {
  const InitialFetch();

  @override
  List<Object?> get props => [];
}

class FetchMore extends RecordListEvent {
  const FetchMore();

  @override
  List<Object?> get props => [];
}

class FetchRecords extends RecordListEvent {
  const FetchRecords();

  @override
  List<Object?> get props => [];
}
