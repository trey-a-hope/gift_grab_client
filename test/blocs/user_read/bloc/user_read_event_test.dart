import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/user_read/user_read.dart';

void main() {
  group(UserReadEvent, () {
    group(ReadUser, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(const ReadUser(), equals(const ReadUser()));
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const ReadUser().props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = ReadUser();
        // ignore: prefer_const_constructors
        final event2 = ReadUser();

        expect(event1, equals(event2));
        expect(event1, isA<UserReadEvent>());
        expect(event1, isA<ReadUser>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = ReadUser();
        expect(event, isA<UserReadEvent>());
        UserReadEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
