part of 'record_create_bloc.dart';

class RecordCreateState extends Equatable implements ErrorState {
  final bool isLoading;
  final String? error;

  const RecordCreateState({
    this.isLoading = false,
    this.error,
  });

  RecordCreateState copyWith({
    bool? isLoading,
    String? error,
  }) =>
      RecordCreateState(
        isLoading: isLoading == true ? true : false,
        error: error,
      );

  @override
  List<Object?> get props => [
        isLoading,
        error,
      ];
}
