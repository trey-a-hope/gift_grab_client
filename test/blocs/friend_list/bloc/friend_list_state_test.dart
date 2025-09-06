import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/friend_list/friend_list.dart';
import 'package:nakama/nakama.dart';

void main() {
  group(
    FriendListState,
    () {
      test(
        TestDescriptions.state.initialValues,
        () {
          const state = FriendListState(
            FriendshipState.mutual,
          );

          expect(state.friendshipState, equals(FriendshipState.mutual));
          expect(state.friends, isEmpty);
          expect(state.cursor, isNull);
          expect(state.isLoading, false);
          expect(state.error, isNull);
        },
      );

      test(
        TestDescriptions.state.valueEquality,
        () {
          const state1 = FriendListState(FriendshipState.mutual);
          const state2 = FriendListState(FriendshipState.mutual);

          expect(state1, equals(state2));
        },
      );

      test(
        'should not be equal when friendshipState differs',
        () {
          const state1 = FriendListState(FriendshipState.mutual);
          const state2 = FriendListState(FriendshipState.outgoingRequest);

          expect(state1, isNot(equals(state2)));
        },
      );

      test(
        TestDescriptions.state.copyWithNoParams,
        () {
          const originalState = FriendListState(FriendshipState.mutual);

          expect(
            originalState.copyWith(),
            const FriendListState(
              FriendshipState.mutual,
              friends: [],
              cursor: null,
              isLoading: false,
              error: null,
            ),
          );
        },
      );

      test(
        TestDescriptions.state.copyWithPreserveState,
        () {
          const originalState = FriendListState(
            FriendshipState.mutual,
            friends: [],
            cursor: null,
            isLoading: false,
            error: null,
          );

          final newState = originalState.copyWith();

          expect(newState.friendshipState, equals(FriendshipState.mutual));
          expect(newState.friends, equals([]));
          expect(newState.cursor, equals(null));
          expect(newState.isLoading, equals(false));
          expect(newState.error, equals(null));
        },
      );

      test(
        TestDescriptions.state.copyWithNewInstance,
        () {
          const originalState = FriendListState(FriendshipState.mutual);

          final newState = originalState.copyWith(
            friends: [],
            cursor: 'test-cursor',
            isLoading: true,
            error: 'test-error',
          );

          expect(newState.friendshipState, equals(FriendshipState.mutual));
          expect(newState.friends, equals([]));
          expect(newState.cursor, equals('test-cursor'));
          expect(newState.isLoading, equals(true));
          expect(newState.error, equals('test-error'));
        },
      );

      test(
        'copyWith should handle null values correctly',
        () {
          const originalState = FriendListState(
            FriendshipState.mutual,
            friends: [],
            cursor: 'test-cursor',
            isLoading: true,
            error: 'test-error',
          );

          final newState = originalState.copyWith(
            cursor: null,
            error: null,
          );

          expect(newState.friendshipState, equals(FriendshipState.mutual));
          expect(newState.friends, equals([]));
          expect(newState.cursor, isNull);
          expect(
              newState.isLoading,
              equals(
                  false)); // Note: current implementation always sets to false when null
          expect(newState.error, isNull);
        },
      );

      test(
        TestDescriptions.state.propsContains,
        () {
          const state = FriendListState(FriendshipState.mutual);

          expect(state.props, hasLength(5));

          expect(state.props, contains(state.friendshipState));
          expect(state.props, contains(state.friends));
          expect(state.props, contains(state.cursor));
          expect(state.props, contains(state.isLoading));
          expect(state.props, contains(state.error));
        },
      );

      test(
        'should support different FriendshipState values',
        () {
          const mutualState = FriendListState(FriendshipState.mutual);
          const outgoingState =
              FriendListState(FriendshipState.outgoingRequest);
          const incomingState =
              FriendListState(FriendshipState.incomingRequest);
          const blockedState = FriendListState(FriendshipState.blocked);

          expect(mutualState.friendshipState, equals(FriendshipState.mutual));
          expect(outgoingState.friendshipState,
              equals(FriendshipState.outgoingRequest));
          expect(incomingState.friendshipState,
              equals(FriendshipState.incomingRequest));
          expect(blockedState.friendshipState, equals(FriendshipState.blocked));
        },
      );

      test(
        'should handle friends list correctly',
        () {
          final mockFriends = <Friend>[];
          final state = FriendListState(
            FriendshipState.mutual,
            friends: mockFriends,
          );

          expect(state.friends, equals(mockFriends));
          expect(state.friends, isEmpty);
        },
      );

      test(
        'should handle isLoading state correctly',
        () {
          const loadingState = FriendListState(
            FriendshipState.mutual,
            isLoading: true,
          );
          const notLoadingState = FriendListState(
            FriendshipState.mutual,
            isLoading: false,
          );

          expect(loadingState.isLoading, isTrue);
          expect(notLoadingState.isLoading, isFalse);
        },
      );

      test(
        'copyWith isLoading parameter behavior',
        () {
          const originalState = FriendListState(
            FriendshipState.mutual,
            isLoading: true,
          );

          // When explicitly setting isLoading to true
          final trueState = originalState.copyWith(isLoading: true);
          expect(trueState.isLoading, isTrue);

          // When explicitly setting isLoading to false
          final falseState = originalState.copyWith(isLoading: false);
          expect(falseState.isLoading, isFalse);

          // When not providing isLoading parameter (null) - current implementation always sets to false
          final nullState = originalState.copyWith();
          expect(nullState.isLoading, isFalse);
        },
      );
    },
  );
}
