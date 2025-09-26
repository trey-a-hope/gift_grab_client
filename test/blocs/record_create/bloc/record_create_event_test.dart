import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/record_create/record_create.dart';

void main() {
  group(RecordCreateEvent, () {
    group(SubmitRecord, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const SubmitRecord(100),
          equals(const SubmitRecord(100)),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const SubmitRecord(100).props,
          [100],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = SubmitRecord(100);
        // ignore: prefer_const_constructors
        final event2 = SubmitRecord(100);

        expect(event1, equals(event2));
        expect(event1, isA<RecordCreateEvent>());
        expect(event1, isA<SubmitRecord>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = SubmitRecord(100);
        expect(event, isA<RecordCreateEvent>());
        RecordCreateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
