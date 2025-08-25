import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/account_delete/account_delete.dart';

void main() {
  group(
    AccountDeleteState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = AccountDeleteState();

          expect(state.success, isNull);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = AccountDeleteState();
          const state2 = AccountDeleteState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const AccountDeleteState().copyWith(),
            const AccountDeleteState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = AccountDeleteState(
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
          const originalState = AccountDeleteState();

          final newState = originalState.copyWith(
            success: null,
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
          const state = AccountDeleteState();

          expect(state.props, hasLength(3));

          expect(state.props, contains(state.success));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );
    },
  );
}
