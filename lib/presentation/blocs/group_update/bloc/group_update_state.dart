part of 'group_update_bloc.dart';

class GroupUpdateState extends Equatable with FormzMixin implements ErrorState {
  final ShortText name;
  final LongText description;

  final Toggle open;
  final FormzSubmissionStatus status;
  final String? success;
  final bool isLoading;
  final String? error;

  const GroupUpdateState({
    this.name = const ShortText.pure(),
    this.description = const LongText.pure(),
    this.open = const Toggle.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.success,
    this.isLoading = false,
    this.error,
  });

  GroupUpdateState copyWith({
    ShortText? name,
    LongText? description,
    Toggle? open,
    FormzSubmissionStatus? status,
    String? success,
    bool? isLoading,
    String? error,
  }) =>
      GroupUpdateState(
        name: name ?? this.name,
        description: description ?? this.description,
        open: open ?? this.open,
        status: status ?? this.status,
        success: success ?? this.success,
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        name,
        description,
        open,
        status,
        success,
        isLoading,
        error,
      ];

  @override
  List<FormzInput> get inputs => [
        name,
        description,
      ];
}
