part of 'record_list_bloc.dart';

class RecordListState extends Equatable implements ErrorState {
  final List<LeaderboardEntry> entries;
  final String? cursor;
  final bool clearCursor;
  final bool isLoading;
  final String? error;

  const RecordListState({
    this.entries = const [],
    this.cursor,
    this.clearCursor = false,
    this.isLoading = false,
    this.error,
  });

  RecordListState copyWith({
    List<LeaderboardEntry>? entries,
    String? cursor,
    bool clearCursor = false,
    bool? isLoading,
    String? error,
  }) =>
      RecordListState(
        entries: clearCursor ? [] : (entries ?? this.entries),
        cursor: clearCursor ? null : (cursor ?? this.cursor),
        isLoading: isLoading == true ? true : false,
        error: error,
      );

  @override
  List<Object?> get props => [
        entries,
        isLoading,
        error,
      ];
}
