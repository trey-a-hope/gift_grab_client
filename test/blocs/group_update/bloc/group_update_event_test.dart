import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/group_update/group_update.dart';
import 'package:nakama/nakama.dart';

void main() {
  group(GroupUpdateEvent, () {
    group(InitForm, () {
      test(TestDescriptions.event.valueEqual, () {
        const group = Group(id: '1', name: 'Test Group');
        expect(
          const InitForm(group),
          equals(const InitForm(group)),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        const group = Group(id: '1', name: 'Test Group');
        expect(
          const InitForm(group).props,
          [group],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        const group = Group(id: '1', name: 'Test Group');
        // ignore: prefer_const_constructors
        final event1 = InitForm(group);
        // ignore: prefer_const_constructors
        final event2 = InitForm(group);

        expect(event1, equals(event2));
        expect(event1, isA<GroupUpdateEvent>());
        expect(event1, isA<InitForm>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const group = Group(id: '1', name: 'Test Group');
        const event = InitForm(group);
        expect(event, isA<GroupUpdateEvent>());
        GroupUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

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
        expect(event1, isA<GroupUpdateEvent>());
        expect(event1, isA<NameChanged>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = NameChanged('test name');
        expect(event, isA<GroupUpdateEvent>());
        GroupUpdateEvent abstractEvent = event;
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
        expect(event1, isA<GroupUpdateEvent>());
        expect(event1, isA<DescriptionChanged>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = DescriptionChanged('test description');
        expect(event, isA<GroupUpdateEvent>());
        GroupUpdateEvent abstractEvent = event;
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
        expect(event1, isA<GroupUpdateEvent>());
        expect(event1, isA<OpenChanged>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = OpenChanged(true);
        expect(event, isA<GroupUpdateEvent>());
        GroupUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(SaveForm, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const SaveForm('group123'),
          equals(const SaveForm('group123')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const SaveForm('group123').props,
          ['group123'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = SaveForm('group123');
        // ignore: prefer_const_constructors
        final event2 = SaveForm('group123');

        expect(event1, equals(event2));
        expect(event1, isA<GroupUpdateEvent>());
        expect(event1, isA<SaveForm>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = SaveForm('group123');
        expect(event, isA<GroupUpdateEvent>());
        GroupUpdateEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
