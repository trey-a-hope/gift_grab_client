part of 'record_delete_bloc.dart';

class RecordDeleteState extends Equatable implements ErrorState {
  final bool deleted;
  final bool isLoading;
  final String? error;

  const RecordDeleteState({
    this.deleted = false,
    this.isLoading = false,
    this.error,
  });

  RecordDeleteState copyWith({
    bool? deleted,
    bool? isLoading,
    String? error,
  }) =>
      RecordDeleteState(
        deleted: deleted ?? this.deleted,
        isLoading: isLoading == true ? true : false,
        error: error,
      );

  @override
  List<Object?> get props => [
        deleted,
        isLoading,
        error,
      ];
}
