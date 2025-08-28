part of 'record_delete_bloc.dart';

class RecordDeleteState extends Equatable implements ErrorState {
  final String? success;
  final bool isLoading;
  final String? error;

  const RecordDeleteState({
    this.success,
    this.isLoading = false,
    this.error,
  });

  RecordDeleteState copyWith({
    String? success,
    bool? isLoading,
    String? error,
  }) =>
      RecordDeleteState(
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
