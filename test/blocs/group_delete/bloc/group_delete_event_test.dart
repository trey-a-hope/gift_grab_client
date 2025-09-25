import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/group_delete/group_delete.dart';

void main() {
  group(GroupDeleteEvent, () {
    group(DeleteGroup, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const DeleteGroup(),
          equals(const DeleteGroup()),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const DeleteGroup().props,
          [],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = DeleteGroup();
        // ignore: prefer_const_constructors
        final event2 = DeleteGroup();

        expect(event1, equals(event2));
        expect(event1, isA<GroupDeleteEvent>());
        expect(event1, isA<DeleteGroup>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = DeleteGroup();
        expect(event, isA<GroupDeleteEvent>());
        GroupDeleteEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
