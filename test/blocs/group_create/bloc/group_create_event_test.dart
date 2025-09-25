import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/group_create/group_create.dart';

void main() {
  group(GroupCreateEvent, () {
    group(NameChanged, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const NameChanged('test name'),
          equals(const NameChanged('test name')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const NameChanged('test name').props,
          ['test name'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = NameChanged('test name');
        // ignore: prefer_const_constructors
        final event2 = NameChanged('test name');

        expect(event1, equals(event2));
        expect(event1, isA<GroupCreateEvent>());
        expect(event1, isA<NameChanged>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = NameChanged('test name');
        expect(event, isA<GroupCreateEvent>());
        GroupCreateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(DescriptionChanged, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const DescriptionChanged('test description'),
          equals(const DescriptionChanged('test description')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const DescriptionChanged('test description').props,
          ['test description'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = DescriptionChanged('test description');
        // ignore: prefer_const_constructors
        final event2 = DescriptionChanged('test description');

        expect(event1, equals(event2));
        expect(event1, isA<GroupCreateEvent>());
        expect(event1, isA<DescriptionChanged>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = DescriptionChanged('test description');
        expect(event, isA<GroupCreateEvent>());
        GroupCreateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(MaxCountChanged, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const MaxCountChanged(10),
          equals(const MaxCountChanged(10)),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const MaxCountChanged(10).props,
          [10],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = MaxCountChanged(10);
        // ignore: prefer_const_constructors
        final event2 = MaxCountChanged(10);

        expect(event1, equals(event2));
        expect(event1, isA<GroupCreateEvent>());
        expect(event1, isA<MaxCountChanged>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = MaxCountChanged(10);
        expect(event, isA<GroupCreateEvent>());
        GroupCreateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(OpenChanged, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const OpenChanged(true),
          equals(const OpenChanged(true)),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const OpenChanged(true).props,
          [true],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = OpenChanged(true);
        // ignore: prefer_const_constructors
        final event2 = OpenChanged(true);

        expect(event1, equals(event2));
        expect(event1, isA<GroupCreateEvent>());
        expect(event1, isA<OpenChanged>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = OpenChanged(true);
        expect(event, isA<GroupCreateEvent>());
        GroupCreateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(SaveForm, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const SaveForm(),
          equals(const SaveForm()),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const SaveForm().props,
          [],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = SaveForm();
        // ignore: prefer_const_constructors
        final event2 = SaveForm();

        expect(event1, equals(event2));
        expect(event1, isA<GroupCreateEvent>());
        expect(event1, isA<SaveForm>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = SaveForm();
        expect(event, isA<GroupCreateEvent>());
        GroupCreateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
