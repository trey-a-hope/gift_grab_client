import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/group_list/group_list.dart';
import 'package:nakama/nakama.dart';

void main() {
  group(
    GroupListState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = GroupListState();

          expect(state.uid, isNull);
          expect(state.query, '');
          expect(state.groups, const <Group>[]);
          expect(state.cursor, isNull);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = GroupListState();
          const state2 = GroupListState();

          expect(state1, equals(state2));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          expect(
            const GroupListState().copyWith(),
            const GroupListState(),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = GroupListState(
            uid: null,
            query: '',
            groups: <Group>[],
            cursor: null,
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.uid, equals(null));
          expect(newState.query, equals(''));
          expect(newState.groups, equals(const <Group>[]));
          expect(newState.cursor, equals(null));
          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = GroupListState();
          const testGroup = Group(id: '1', name: 'Test Group');

          final newState = originalState.copyWith(
            uid: 'user123',
            query: 'test search',
            groups: [testGroup],
            cursor: 'cursor123',
            isLoading: true,
            error: 'Test error',
          );

          expect(newState.uid, equals('user123'));
          expect(newState.query, equals('test search'));
          expect(newState.groups, equals([testGroup]));
          expect(newState.cursor, equals('cursor123'));
          expect(newState.isLoading, equals(true));
          expect(newState.error, equals('Test error'));
        },
      );

      test(
        TestDescriptions.state.propsContains,
        () {
          const state = GroupListState();

          expect(state.props, hasLength(6));

          expect(state.props, contains(state.uid));
          expect(state.props, contains(state.query));
          expect(state.props, contains(state.groups));
          expect(state.props, contains(state.cursor));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );

      test(
        'copyWith clearCursor functionality',
        () {
          const originalState = GroupListState(
            cursor: 'original_cursor',
          );

          final newStateWithClearCursor = originalState.copyWith(
            clearCursor: true,
          );

          expect(newStateWithClearCursor.cursor, isNull);
        },
      );
    },
  );
}
