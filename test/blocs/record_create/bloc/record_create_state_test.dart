import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/record_create/record_create.dart';

void main() {
  group(
    RecordCreateState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = RecordCreateState();

          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = RecordCreateState();
          const state2 = RecordCreateState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const RecordCreateState().copyWith(),
            const RecordCreateState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = RecordCreateState(
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = RecordCreateState();

          final newState = originalState.copyWith(
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
          const state = RecordCreateState();

          expect(state.props, hasLength(2));

          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );
    },
  );
}
