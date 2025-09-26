part of 'user_update_bloc.dart';

class UserUpdateState extends Equatable implements ErrorState {
  final FormzSubmissionStatus status;
  final ShortText username;
  final String? success;
  final bool isLoading;
  final String? error;

  const UserUpdateState({
    this.status = FormzSubmissionStatus.initial,
    this.username = const ShortText.pure(),
    this.success,
    this.isLoading = false,
    this.error,
  });

  UserUpdateState copyWith({
    FormzSubmissionStatus? status,
    ShortText? username,
    String? success,
    bool? isLoading,
    String? error,
  }) =>
      UserUpdateState(
        status: status ?? this.status,
        username: username ?? this.username,
        success: success,
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        status,
        username,
        success,
        isLoading,
        error,
      ];
}
