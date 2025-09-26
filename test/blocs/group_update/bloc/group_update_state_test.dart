import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/group_update/group_update.dart';
import 'package:gift_grab_ui/ui.dart';

void main() {
  group(
    GroupUpdateState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = GroupUpdateState();

          expect(state.name, const ShortText.pure());
          expect(state.description, const LongText.pure());
          expect(state.open, const Toggle.pure());
          expect(state.status, FormzSubmissionStatus.initial);
          expect(state.success, isNull);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = GroupUpdateState();
          const state2 = GroupUpdateState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const GroupUpdateState().copyWith(),
            const GroupUpdateState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = GroupUpdateState(
            name: ShortText.pure(),
            description: LongText.pure(),
            open: Toggle.pure(),
            status: FormzSubmissionStatus.initial,
            success: null,
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.name, equals(const ShortText.pure()));
          expect(newState.description, equals(const LongText.pure()));
          expect(newState.open, equals(const Toggle.pure()));
          expect(newState.status, equals(FormzSubmissionStatus.initial));
          expect(newState.success, equals(null));
          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = GroupUpdateState();

          final newState = originalState.copyWith(
            name: const ShortText.dirty('Updated Name'),
            description: const LongText.dirty('Updated Description'),
            open: const Toggle.dirty(false),
            status: FormzSubmissionStatus.success,
            success: 'Group updated successfully',
            isLoading: true,
            error: 'Test error',
          );

          expect(newState.name, equals(const ShortText.dirty('Updated Name')));
          expect(newState.description,
              equals(const LongText.dirty('Updated Description')));
          expect(newState.open, equals(const Toggle.dirty(false)));
          expect(newState.status, equals(FormzSubmissionStatus.success));
          expect(newState.success, equals('Group updated successfully'));
          expect(newState.isLoading, equals(true));
          expect(newState.error, equals('Test error'));
        },
      );

      test(
        TestDescriptions.state.propsContains,
        () {
          const state = GroupUpdateState();

          expect(state.props, hasLength(7));

          expect(state.props, contains(state.name));
          expect(state.props, contains(state.description));
          expect(state.props, contains(state.open));
          expect(state.props, contains(state.status));
          expect(state.props, contains(state.success));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );

      test(
        'FormzMixin integration - inputs list contains correct form inputs',
        () {
          const state = GroupUpdateState();

          expect(state.inputs, hasLength(2));
          expect(state.inputs, contains(state.name));
          expect(state.inputs, contains(state.description));
        },
      );
    },
  );
}
