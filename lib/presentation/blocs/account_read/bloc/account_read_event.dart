part of 'account_read_bloc.dart';

sealed class AccountReadEvent extends Equatable {
  const AccountReadEvent();
}

class ReadAccount extends AccountReadEvent {
  const ReadAccount();

  @override
  List<Object?> get props => [];
}
