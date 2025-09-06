part of 'record_list_bloc.dart';

class RecordListState extends Equatable implements ErrorState {
  final List<LeaderboardEntry> entries;
  final String? cursor;
  final bool isLoading;
  final String? error;

  const RecordListState({
    this.entries = const [],
    this.cursor,
    this.isLoading = false,
    this.error,
  });

  RecordListState copyWith({
    List<LeaderboardEntry>? entries,
    String? cursor,
    bool? isLoading,
    String? error,
  }) =>
      RecordListState(
        entries: entries ?? this.entries,
        cursor: cursor,
        isLoading: isLoading.falseIfNull(),
        error: error,
      );

  @override
  List<Object?> get props => [
        entries,
        cursor,
        isLoading,
        error,
      ];
}
