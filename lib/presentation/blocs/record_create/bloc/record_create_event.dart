part of 'record_create_bloc.dart';

sealed class RecordCreateEvent extends Equatable {
  const RecordCreateEvent();
}

class SubmitRecord extends RecordCreateEvent {
  final int score;

  const SubmitRecord(this.score);

  @override
  List<Object?> get props => [score];
}
