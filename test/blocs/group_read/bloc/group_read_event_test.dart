import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/group_read/group_read.dart';

void main() {
  group(GroupReadEvent, () {
    group(ReadGroup, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const ReadGroup(),
          equals(const ReadGroup()),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const ReadGroup().props,
          [],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = ReadGroup();
        // ignore: prefer_const_constructors
        final event2 = ReadGroup();

        expect(event1, equals(event2));
        expect(event1, isA<GroupReadEvent>());
        expect(event1, isA<ReadGroup>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = ReadGroup();
        expect(event, isA<GroupReadEvent>());
        GroupReadEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
