part of 'account_update_bloc.dart';

sealed class AccountUpdateEvent extends Equatable {
  const AccountUpdateEvent();
}

class UpdateAccount extends AccountUpdateEvent {
  final String username;

  const UpdateAccount(this.username);

  @override
  List<Object?> get props => [username];
}

class LinkEmail extends AccountUpdateEvent {
  final String email;
  final String password;

  const LinkEmail(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class UnlinkEmail extends AccountUpdateEvent {
  const UnlinkEmail();

  @override
  List<Object?> get props => [];
}

class LinkGoogle extends AccountUpdateEvent {
  const LinkGoogle();

  @override
  List<Object?> get props => [];
}

class UnlinkGoogle extends AccountUpdateEvent {
  const UnlinkGoogle();

  @override
  List<Object?> get props => [];
}

class LinkApple extends AccountUpdateEvent {
  const LinkApple();

  @override
  List<Object?> get props => [];
}

class UnlinkApple extends AccountUpdateEvent {
  const UnlinkApple();

  @override
  List<Object?> get props => [];
}
