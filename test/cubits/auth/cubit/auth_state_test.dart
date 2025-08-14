import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/cubits/auth/auth.dart';

void main() {
  group(
    AuthState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = AuthState();

          expect(state.authenticated, false);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = AuthState();
          const state2 = AuthState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const AuthState().copyWith(),
            const AuthState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = AuthState(
            authenticated: false,
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.authenticated, equals(false));
          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = AuthState();

          final newState = originalState.copyWith(
            authenticated: false,
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
          const state = AuthState();

          expect(state.props, hasLength(3));

          expect(state.props, contains(state.authenticated));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );
    },
  );
}
