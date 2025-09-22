part of 'group_read_bloc.dart';

class GroupReadState extends Equatable implements ErrorState {
  final Group? group;
  final bool isLoading;
  final String? error;

  const GroupReadState({
    this.group,
    this.isLoading = false,
    this.error,
  });

  GroupReadState copyWith({
    Group? group,
    bool? isLoading,
    String? error,
  }) =>
      GroupReadState(
        group: group ?? this.group,
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        group,
        isLoading,
        error,
      ];
}
