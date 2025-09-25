import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/group_delete/group_delete.dart';

void main() {
  group(
    GroupDeleteState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = GroupDeleteState();

          expect(state.success, isNull);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = GroupDeleteState();
          const state2 = GroupDeleteState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const GroupDeleteState().copyWith(),
            const GroupDeleteState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = GroupDeleteState(
            success: null,
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.success, equals(null));
          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = GroupDeleteState();

          final newState = originalState.copyWith(
            success: 'Group deleted successfully',
            isLoading: true,
            error: 'Test error',
          );

          expect(newState.success, equals('Group deleted successfully'));
          expect(newState.isLoading, equals(true));
          expect(newState.error, equals('Test error'));
        },
      );

      test(
        TestDescriptions.state.propsContains,
        () {
          const state = GroupDeleteState();

          expect(state.props, hasLength(3));

          expect(state.props, contains(state.success));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );
    },
  );
}
