import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/friend_update/friend_update.dart';

void main() {
  group(FriendUpdateEvent, () {
    group(SendRequest, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const SendRequest('user_123'),
          equals(const SendRequest('user_123')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const SendRequest('user_123').props,
          ['user_123'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = SendRequest('user_123');
        // ignore: prefer_const_constructors
        final event2 = SendRequest('user_123');

        expect(event1, equals(event2));
        expect(event1, isA<FriendUpdateEvent>());
        expect(event1, isA<SendRequest>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = SendRequest('user_123');
        expect(event, isA<FriendUpdateEvent>());
        FriendUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });

      test(TestDescriptions.event.diffProps, () {
        const event1 = SendRequest('user_123');
        const event2 = SendRequest('user_456');

        expect(event1, isNot(equals(event2)));
      });
    });

    group(CancelRequest, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const CancelRequest('user_123'),
          equals(const CancelRequest('user_123')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const CancelRequest('user_123').props,
          ['user_123'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = CancelRequest('user_123');
        // ignore: prefer_const_constructors
        final event2 = CancelRequest('user_123');

        expect(event1, equals(event2));
        expect(event1, isA<FriendUpdateEvent>());
        expect(event1, isA<CancelRequest>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = CancelRequest('user_123');
        expect(event, isA<FriendUpdateEvent>());
        FriendUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });

      test(TestDescriptions.event.diffProps, () {
        const event1 = CancelRequest('user_123');
        const event2 = CancelRequest('user_456');

        expect(event1, isNot(equals(event2)));
      });
    });

    group(RejectRequest, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const RejectRequest('user_123'),
          equals(const RejectRequest('user_123')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const RejectRequest('user_123').props,
          ['user_123'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = RejectRequest('user_123');
        // ignore: prefer_const_constructors
        final event2 = RejectRequest('user_123');

        expect(event1, equals(event2));
        expect(event1, isA<FriendUpdateEvent>());
        expect(event1, isA<RejectRequest>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = RejectRequest('user_123');
        expect(event, isA<FriendUpdateEvent>());
        FriendUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });

      test(TestDescriptions.event.diffProps, () {
        const event1 = RejectRequest('user_123');
        const event2 = RejectRequest('user_456');

        expect(event1, isNot(equals(event2)));
      });
    });

    group(AcceptRequest, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const AcceptRequest('user_123'),
          equals(const AcceptRequest('user_123')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const AcceptRequest('user_123').props,
          ['user_123'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = AcceptRequest('user_123');
        // ignore: prefer_const_constructors
        final event2 = AcceptRequest('user_123');

        expect(event1, equals(event2));
        expect(event1, isA<FriendUpdateEvent>());
        expect(event1, isA<AcceptRequest>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = AcceptRequest('user_123');
        expect(event, isA<FriendUpdateEvent>());
        FriendUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });

      test(TestDescriptions.event.diffProps, () {
        const event1 = AcceptRequest('user_123');
        const event2 = AcceptRequest('user_456');

        expect(event1, isNot(equals(event2)));
      });
    });

    group(DeleteFriend, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const DeleteFriend('user_123'),
          equals(const DeleteFriend('user_123')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const DeleteFriend('user_123').props,
          ['user_123'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = DeleteFriend('user_123');
        // ignore: prefer_const_constructors
        final event2 = DeleteFriend('user_123');

        expect(event1, equals(event2));
        expect(event1, isA<FriendUpdateEvent>());
        expect(event1, isA<DeleteFriend>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = DeleteFriend('user_123');
        expect(event, isA<FriendUpdateEvent>());
        FriendUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });

      test(TestDescriptions.event.diffProps, () {
        const event1 = DeleteFriend('user_123');
        const event2 = DeleteFriend('user_456');

        expect(event1, isNot(equals(event2)));
      });
    });

    group(BlockFriend, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const BlockFriend('user_123'),
          equals(const BlockFriend('user_123')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const BlockFriend('user_123').props,
          ['user_123'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = BlockFriend('user_123');
        // ignore: prefer_const_constructors
        final event2 = BlockFriend('user_123');

        expect(event1, equals(event2));
        expect(event1, isA<FriendUpdateEvent>());
        expect(event1, isA<BlockFriend>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = BlockFriend('user_123');
        expect(event, isA<FriendUpdateEvent>());
        FriendUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });

      test(TestDescriptions.event.diffProps, () {
        const event1 = BlockFriend('user_123');
        const event2 = BlockFriend('user_456');

        expect(event1, isNot(equals(event2)));
      });
    });

    group(UnblockFriend, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const UnblockFriend('user_123'),
          equals(const UnblockFriend('user_123')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const UnblockFriend('user_123').props,
          ['user_123'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = UnblockFriend('user_123');
        // ignore: prefer_const_constructors
        final event2 = UnblockFriend('user_123');

        expect(event1, equals(event2));
        expect(event1, isA<FriendUpdateEvent>());
        expect(event1, isA<UnblockFriend>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = UnblockFriend('user_123');
        expect(event, isA<FriendUpdateEvent>());
        FriendUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });

      test(TestDescriptions.event.diffProps, () {
        const event1 = UnblockFriend('user_123');
        const event2 = UnblockFriend('user_456');

        expect(event1, isNot(equals(event2)));
      });
    });
  });
}
