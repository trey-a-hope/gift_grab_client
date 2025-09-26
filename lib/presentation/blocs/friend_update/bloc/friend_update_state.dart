part of 'friend_update_bloc.dart';

class FriendUpdateState extends Equatable implements ErrorState {
  final String? success;
  final bool isLoading;
  final String? error;

  const FriendUpdateState({
    this.success,
    this.isLoading = false,
    this.error,
  });

  FriendUpdateState copyWith({
    String? success,
    bool? isLoading,
    String? error,
  }) =>
      FriendUpdateState(
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
