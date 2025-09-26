import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/user_update/user_update.dart';
import 'package:gift_grab_ui/ui.dart';

void main() {
  group(
    UserUpdateState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = UserUpdateState();

          expect(state.status, FormzSubmissionStatus.initial);
          expect(state.username, const ShortText.pure());
          expect(state.success, isNull);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = UserUpdateState();
          const state2 = UserUpdateState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const UserUpdateState().copyWith(),
            const UserUpdateState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = UserUpdateState(
            status: FormzSubmissionStatus.initial,
            username: ShortText.pure(),
            success: null,
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.status, equals(FormzSubmissionStatus.initial));
          expect(newState.username, equals(const ShortText.pure()));
          expect(newState.success, equals(null));
          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = UserUpdateState();

          final newState = originalState.copyWith(
            status: FormzSubmissionStatus.initial,
            username: const ShortText.pure(),
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
          const state = UserUpdateState();

          expect(state.props, hasLength(5));

          expect(state.props, contains(state.status));
          expect(state.props, contains(state.username));
          expect(state.props, contains(state.success));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );
    },
  );
}
