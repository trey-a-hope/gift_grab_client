import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/user_read/bloc/user_read_bloc.dart';

void main() {
  group(
    UserReadState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = UserReadState();

          expect(state.user, isNull);
          expect(state.isMyProfile, false);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = UserReadState();
          const state2 = UserReadState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const UserReadState().copyWith(),
            const UserReadState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = UserReadState(
            user: null,
            isMyProfile: false,
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.user, equals(null));
          expect(newState.isMyProfile, equals(false));
          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = UserReadState();

          final newState = originalState.copyWith(
            user: null,
            isMyProfile: false,
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
          const state = UserReadState();

          expect(state.props, hasLength(4));

          expect(state.props, contains(state.user));
          expect(state.props, contains(state.isMyProfile));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );
    },
  );
}
