part of 'account_read_bloc.dart';

class AccountReadState extends Equatable implements ErrorState {
  final Account? account;
  final bool isLoading;
  final String? error;

  const AccountReadState({
    this.account,
    this.isLoading = false,
    this.error,
  });

  AccountReadState copyWith({
    Account? account,
    bool? isLoading,
    String? error,
  }) =>
      AccountReadState(
        account: account ?? this.account,
        isLoading: isLoading == true ? true : false,
        error: error,
      );

  @override
  List<Object?> get props => [
        account,
        isLoading,
        error,
      ];
}
