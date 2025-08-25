import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';

void main() {
  group(
    AccountReadState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = AccountReadState();

          expect(state.account, isNull);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = AccountReadState();
          const state2 = AccountReadState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const AccountReadState().copyWith(),
            const AccountReadState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = AccountReadState(
            account: null,
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.account, equals(null));
          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = AccountReadState();

          final newState = originalState.copyWith(
            account: null,
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
          const state = AccountReadState();

          expect(state.props, hasLength(3));

          expect(state.props, contains(state.account));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );
    },
  );
}
