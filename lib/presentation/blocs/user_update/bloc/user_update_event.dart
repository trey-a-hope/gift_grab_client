part of 'user_update_bloc.dart';

sealed class UserUpdateEvent extends Equatable {
  const UserUpdateEvent();
}

class Init extends UserUpdateEvent {
  const Init();

  @override
  List<Object?> get props => [];
}

class UsernameChange extends UserUpdateEvent {
  final String username;

  const UsernameChange(this.username);

  @override
  List<Object?> get props => [];
}

class SaveForm extends UserUpdateEvent {
  const SaveForm();

  @override
  List<Object?> get props => [];
}
