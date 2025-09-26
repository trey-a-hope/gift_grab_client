import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/account_update/account_update.dart';

void main() {
  group(AccountUpdateEvent, () {
    group(UpdateAccount, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const UpdateAccount('testUser'),
          equals(const UpdateAccount('testUser')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const UpdateAccount('testUser').props,
          ['testUser'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = UpdateAccount('testUser');
        // ignore: prefer_const_constructors
        final event2 = UpdateAccount('testUser');

        expect(event1, equals(event2));
        expect(event1, isA<AccountUpdateEvent>());
        expect(event1, isA<UpdateAccount>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = UpdateAccount('testUser');
        expect(event, isA<AccountUpdateEvent>());
        AccountUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(LinkEmail, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const LinkEmail('test@example.com', 'password123'),
          equals(const LinkEmail('test@example.com', 'password123')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const LinkEmail('test@example.com', 'password123').props,
          ['test@example.com', 'password123'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = LinkEmail('test@example.com', 'password123');
        // ignore: prefer_const_constructors
        final event2 = LinkEmail('test@example.com', 'password123');

        expect(event1, equals(event2));
        expect(event1, isA<AccountUpdateEvent>());
        expect(event1, isA<LinkEmail>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = LinkEmail('test@example.com', 'password123');
        expect(event, isA<AccountUpdateEvent>());
        AccountUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(UnlinkEmail, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(const UnlinkEmail(), equals(const UnlinkEmail()));
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const UnlinkEmail().props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = UnlinkEmail();
        // ignore: prefer_const_constructors
        final event2 = UnlinkEmail();

        expect(event1, equals(event2));
        expect(event1, isA<AccountUpdateEvent>());
        expect(event1, isA<UnlinkEmail>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = UnlinkEmail();
        expect(event, isA<AccountUpdateEvent>());
        AccountUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(LinkGoogle, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(const LinkGoogle(), equals(const LinkGoogle()));
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const LinkGoogle().props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = LinkGoogle();
        // ignore: prefer_const_constructors
        final event2 = LinkGoogle();

        expect(event1, equals(event2));
        expect(event1, isA<AccountUpdateEvent>());
        expect(event1, isA<LinkGoogle>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = LinkGoogle();
        expect(event, isA<AccountUpdateEvent>());
        AccountUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(UnlinkGoogle, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(const UnlinkGoogle(), equals(const UnlinkGoogle()));
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const UnlinkGoogle().props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = UnlinkGoogle();
        // ignore: prefer_const_constructors
        final event2 = UnlinkGoogle();

        expect(event1, equals(event2));
        expect(event1, isA<AccountUpdateEvent>());
        expect(event1, isA<UnlinkGoogle>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = UnlinkGoogle();
        expect(event, isA<AccountUpdateEvent>());
        AccountUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(LinkApple, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(const LinkApple(), equals(const LinkApple()));
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const LinkApple().props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = LinkApple();
        // ignore: prefer_const_constructors
        final event2 = LinkApple();

        expect(event1, equals(event2));
        expect(event1, isA<AccountUpdateEvent>());
        expect(event1, isA<LinkApple>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = LinkApple();
        expect(event, isA<AccountUpdateEvent>());
        AccountUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(UnlinkApple, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(const UnlinkApple(), equals(const UnlinkApple()));
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const UnlinkApple().props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = UnlinkApple();
        // ignore: prefer_const_constructors
        final event2 = UnlinkApple();

        expect(event1, equals(event2));
        expect(event1, isA<AccountUpdateEvent>());
        expect(event1, isA<UnlinkApple>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = UnlinkApple();
        expect(event, isA<AccountUpdateEvent>());
        AccountUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
