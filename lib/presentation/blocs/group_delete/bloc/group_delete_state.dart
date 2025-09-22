part of 'group_delete_bloc.dart';

class GroupDeleteState extends Equatable implements ErrorState {
  final String? success;
  final bool isLoading;
  final String? error;

  const GroupDeleteState({
    this.success,
    this.isLoading = false,
    this.error,
  });

  GroupDeleteState copyWith({
    String? success,
    bool? isLoading,
    String? error,
  }) =>
      GroupDeleteState(
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
