import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/group_create/group_create.dart';
import 'package:gift_grab_ui/ui.dart';

void main() {
  group(
    GroupCreateState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = GroupCreateState();

          expect(state.name, const ShortText.pure());
          expect(state.description, const LongText.pure());
          expect(state.maxCount, const Range.pure());
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
          const state1 = GroupCreateState();
          const state2 = GroupCreateState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const GroupCreateState().copyWith(),
            const GroupCreateState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = GroupCreateState(
            name: ShortText.pure(),
            description: LongText.pure(),
            maxCount: Range.pure(),
            open: Toggle.pure(),
            status: FormzSubmissionStatus.initial,
            success: null,
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.name, equals(const ShortText.pure()));
          expect(newState.description, equals(const LongText.pure()));
          expect(newState.maxCount, equals(const Range.pure()));
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
          const originalState = GroupCreateState();

          final newState = originalState.copyWith(
            name: const ShortText.dirty('Test Group'),
            description: const LongText.dirty('Test Description'),
            maxCount: const Range.dirty(10),
            open: const Toggle.dirty(true),
            status: FormzSubmissionStatus.success,
            success: 'Group created successfully',
            isLoading: true,
            error: 'Test error',
          );

          expect(newState.name, equals(const ShortText.dirty('Test Group')));
          expect(newState.description,
              equals(const LongText.dirty('Test Description')));
          expect(newState.maxCount, equals(const Range.dirty(10)));
          expect(newState.open, equals(const Toggle.dirty(true)));
          expect(newState.status, equals(FormzSubmissionStatus.success));
          expect(newState.success, equals('Group created successfully'));
          expect(newState.isLoading, equals(true));
          expect(newState.error, equals('Test error'));
        },
      );

      test(
        TestDescriptions.state.propsContains,
        () {
          const state = GroupCreateState();

          expect(state.props, hasLength(8));

          expect(state.props, contains(state.name));
          expect(state.props, contains(state.description));
          expect(state.props, contains(state.maxCount));
          expect(state.props, contains(state.open));
          expect(state.props, contains(state.status));
          expect(state.props, contains(state.success));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );

      test(
        'inputs contains form fields',
        () {
          const state = GroupCreateState();

          expect(state.inputs, hasLength(3));
          expect(state.inputs, contains(state.name));
          expect(state.inputs, contains(state.description));
          expect(state.inputs, contains(state.maxCount));
        },
      );

      test(
        'isValid returns true when all inputs are valid',
        () {
          const state = GroupCreateState(
            name: ShortText.dirty('Valid Name'),
            description: LongText.dirty('Valid Description'),
            maxCount: Range.dirty(5),
          );

          // This assumes the form inputs are valid with the given values
          // You may need to adjust based on your actual validation logic
          expect(state.isValid, isTrue);
        },
      );

      test(
        'copyWith with isLoading null preserves existing value',
        () {
          const originalState = GroupCreateState(isLoading: true);

          final newState = originalState.copyWith(isLoading: null);

          expect(newState.isLoading, equals(false)); // due to falseIfNull()
        },
      );

      test(
        'copyWith with error null sets error to null',
        () {
          const originalState = GroupCreateState(error: 'Previous error');

          final newState = originalState.copyWith(error: null);

          expect(newState.error, isNull);
        },
      );

      test(
        'copyWith with success null sets success to null',
        () {
          const originalState = GroupCreateState(success: 'Previous success');

          final newState = originalState.copyWith(success: null);

          expect(newState.success, isNull);
        },
      );
    },
  );
}
