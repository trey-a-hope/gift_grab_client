import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/user_list/user_list.dart';

void main() {
  group(
    UserListState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = UserListState();

          expect(state.query, isEmpty);
          expect(state.users, isEmpty);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = UserListState();
          const state2 = UserListState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const UserListState().copyWith(),
            const UserListState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = UserListState(
            query: '',
            users: [],
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.query, equals(''));
          expect(newState.users, equals([]));
          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = UserListState();

          final newState = originalState.copyWith(
            query: '',
            users: [],
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
          const state = UserListState();

          expect(state.props, hasLength(4));

          expect(state.props, contains(state.query));
          expect(state.props, contains(state.users));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );
    },
  );
}
