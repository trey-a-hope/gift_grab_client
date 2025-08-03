part of 'record_create_bloc.dart';

class RecordCreateState extends Equatable implements ErrorState {
  final String? success;
  final bool isLoading;
  final String? error;

  const RecordCreateState({
    this.success,
    this.isLoading = false,
    this.error,
  });

  RecordCreateState copyWith({
    String? success,
    bool? isLoading,
    String? error,
  }) =>
      RecordCreateState(
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
