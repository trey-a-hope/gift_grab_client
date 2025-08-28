import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/user_update/user_update.dart';

void main() {
  group(UserUpdateEvent, () {
    group(Init, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(const Init(), equals(const Init()));
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const Init().props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = Init();
        // ignore: prefer_const_constructors
        final event2 = Init();

        expect(event1, equals(event2));
        expect(event1, isA<UserUpdateEvent>());
        expect(event1, isA<Init>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = Init();
        expect(event, isA<UserUpdateEvent>());
        UserUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(UsernameChange, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const UsernameChange('testUser'),
          equals(const UsernameChange('testUser')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const UsernameChange('testUser').props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = UsernameChange('testUser');
        // ignore: prefer_const_constructors
        final event2 = UsernameChange('testUser');

        expect(event1, equals(event2));
        expect(event1, isA<UserUpdateEvent>());
        expect(event1, isA<UsernameChange>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = UsernameChange('testUser');
        expect(event, isA<UserUpdateEvent>());
        UserUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(SaveForm, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(const SaveForm(), equals(const SaveForm()));
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const SaveForm().props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = SaveForm();
        // ignore: prefer_const_constructors
        final event2 = SaveForm();

        expect(event1, equals(event2));
        expect(event1, isA<UserUpdateEvent>());
        expect(event1, isA<SaveForm>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = SaveForm();
        expect(event, isA<UserUpdateEvent>());
        UserUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
