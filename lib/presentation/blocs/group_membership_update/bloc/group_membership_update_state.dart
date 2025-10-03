part of 'group_membership_update_bloc.dart';

class GroupMembershipUpdateState extends Equatable implements ErrorState {
  final String groupId;
  final String? success;
  final bool isLoading;
  final String? error;

  const GroupMembershipUpdateState(
    this.groupId, {
    this.success,
    this.isLoading = false,
    this.error,
  });

  GroupMembershipUpdateState copyWith({
    String? success,
    bool? isLoading,
    String? error,
  }) =>
      GroupMembershipUpdateState(
        this.groupId,
        success: success,
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        groupId,
        success,
        isLoading,
        error,
      ];
}
