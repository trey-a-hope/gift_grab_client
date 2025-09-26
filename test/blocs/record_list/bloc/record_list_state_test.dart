import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/record_list/record_list.dart';

void main() {
  group(
    RecordListState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = RecordListState();

          expect(state.entries, isEmpty);
          expect(state.cursor, isNull);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = RecordListState();
          const state2 = RecordListState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const RecordListState().copyWith(),
            const RecordListState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = RecordListState(
            entries: [],
            cursor: null,
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.entries, equals([]));
          expect(newState.cursor, equals(null));
          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = RecordListState();

          final newState = originalState.copyWith(
            entries: [],
            cursor: null,
            isLoading: false,
            error: null,
          );

          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.propsContains,
        () {
          const state = RecordListState();

          expect(state.props, hasLength(4));

          expect(state.props, contains(state.entries));
          expect(state.props, contains(state.cursor));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );
    },
  );
}
