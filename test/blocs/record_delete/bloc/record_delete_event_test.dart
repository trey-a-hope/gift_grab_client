import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/record_delete/record_delete.dart';

void main() {
  group(RecordDeleteEvent, () {
    group(DeleteRecord, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const DeleteRecord(),
          equals(const DeleteRecord()),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const DeleteRecord().props,
          [],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = DeleteRecord();
        // ignore: prefer_const_constructors
        final event2 = DeleteRecord();

        expect(event1, equals(event2));
        expect(event1, isA<RecordDeleteEvent>());
        expect(event1, isA<DeleteRecord>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = DeleteRecord();
        expect(event, isA<RecordDeleteEvent>());
        RecordDeleteEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
