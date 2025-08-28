import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/record_list/record_list.dart';

void main() {
  group(RecordListEvent, () {
    group(InitialFetch, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const InitialFetch(),
          equals(const InitialFetch()),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const InitialFetch().props,
          [],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = InitialFetch();
        // ignore: prefer_const_constructors
        final event2 = InitialFetch();

        expect(event1, equals(event2));
        expect(event1, isA<RecordListEvent>());
        expect(event1, isA<InitialFetch>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = InitialFetch();
        expect(event, isA<RecordListEvent>());
        RecordListEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(FetchMore, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const FetchMore(),
          equals(const FetchMore()),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const FetchMore().props,
          [],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = FetchMore();
        // ignore: prefer_const_constructors
        final event2 = FetchMore();

        expect(event1, equals(event2));
        expect(event1, isA<RecordListEvent>());
        expect(event1, isA<FetchMore>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = FetchMore();
        expect(event, isA<RecordListEvent>());
        RecordListEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(FetchRecords, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const FetchRecords(),
          equals(const FetchRecords()),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const FetchRecords().props,
          [],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = FetchRecords();
        // ignore: prefer_const_constructors
        final event2 = FetchRecords();

        expect(event1, equals(event2));
        expect(event1, isA<RecordListEvent>());
        expect(event1, isA<FetchRecords>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = FetchRecords();
        expect(event, isA<RecordListEvent>());
        RecordListEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
