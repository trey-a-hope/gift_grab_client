part of 'group_create_bloc.dart';

class GroupCreateState extends Equatable with FormzMixin implements ErrorState {
  final ShortText name;
  final LongText description;
  final Range maxCount;
  final Toggle open;
  final FormzSubmissionStatus status;
  final String? success;
  final bool isLoading;
  final String? error;

  const GroupCreateState({
    this.name = const ShortText.pure(),
    this.description = const LongText.pure(),
    this.maxCount = const Range.pure(),
    this.open = const Toggle.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.success,
    this.isLoading = false,
    this.error,
  });

  GroupCreateState copyWith({
    ShortText? name,
    LongText? description,
    Range? maxCount,
    Toggle? open,
    FormzSubmissionStatus? status,
    String? success,
    bool? isLoading,
    String? error,
  }) =>
      GroupCreateState(
        name: name ?? this.name,
        description: description ?? this.description,
        maxCount: maxCount ?? this.maxCount,
        open: open ?? this.open,
        status: status ?? this.status,
        success: success,
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        name,
        description,
        maxCount,
        open,
        status,
        success,
        isLoading,
        error,
      ];

  @override
  List<FormzInput> get inputs => [name, description, maxCount];
}
