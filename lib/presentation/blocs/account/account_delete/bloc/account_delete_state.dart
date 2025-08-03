part of 'account_delete_bloc.dart';

class AccountDeleteState extends Equatable implements ErrorState {
  final String? success;
  final bool isLoading;
  final String? error;

  const AccountDeleteState({
    this.success,
    this.isLoading = false,
    this.error,
  });

  AccountDeleteState copyWith({
    String? success,
    bool? isLoading,
    String? error,
  }) =>
      AccountDeleteState(
        success: success,
        isLoading: isLoading == true ? true : false,
        error: error,
      );

  @override
  List<Object?> get props => [
        success,
        isLoading,
        error,
      ];
}
