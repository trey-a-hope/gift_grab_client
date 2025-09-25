import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/group_read/group_read.dart';
import 'package:nakama/nakama.dart';

void main() {
  group(
    GroupReadState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = GroupReadState();

          expect(state.group, isNull);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = GroupReadState();
          const state2 = GroupReadState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const GroupReadState().copyWith(),
            const GroupReadState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = GroupReadState(
            group: null,
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.group, equals(null));
          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = GroupReadState();
          const testGroup = Group(id: '1', name: 'Test Group');

          final newState = originalState.copyWith(
            group: testGroup,
            isLoading: true,
            error: 'Test error',
          );

          expect(newState.group, equals(testGroup));
          expect(newState.isLoading, equals(true));
          expect(newState.error, equals('Test error'));
        },
      );

      test(
        TestDescriptions.state.propsContains,
        () {
          const state = GroupReadState();

          expect(state.props, hasLength(3));

          expect(state.props, contains(state.group));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );
    },
  );
}
