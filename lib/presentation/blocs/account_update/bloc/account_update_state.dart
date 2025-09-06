part of 'account_update_bloc.dart';

class AccountUpdateState extends Equatable implements ErrorState {
  final String? success;
  final bool isLoading;
  final String? error;

  const AccountUpdateState({
    this.success,
    this.isLoading = false,
    this.error,
  });

  AccountUpdateState copyWith({
    String? success,
    bool? isLoading,
    String? error,
  }) =>
      AccountUpdateState(
        success: success,
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        success,
        isLoading,
        error,
      ];
}
