part of 'account_delete_bloc.dart';

sealed class AccountDeleteEvent extends Equatable {
  const AccountDeleteEvent();
}

class DeleteAccount extends AccountDeleteEvent {
  const DeleteAccount();

  @override
  List<Object?> get props => [];
}
