part of 'user_read_bloc.dart';

sealed class UserReadEvent extends Equatable {
  const UserReadEvent();
}

class ReadUser extends UserReadEvent {
  const ReadUser();

  @override
  List<Object?> get props => [];
}
