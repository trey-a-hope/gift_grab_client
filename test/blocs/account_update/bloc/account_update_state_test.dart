import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/account_update/bloc/account_update_bloc.dart';

void main() {
  group(
    AccountUpdateState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = AccountUpdateState();

          expect(state.success, isNull);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = AccountUpdateState();
          const state2 = AccountUpdateState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const AccountUpdateState().copyWith(),
            const AccountUpdateState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = AccountUpdateState(
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
          const originalState = AccountUpdateState();

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
          const state = AccountUpdateState();

          expect(state.props, hasLength(3));

          expect(state.props, contains(state.success));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );
    },
  );
}
