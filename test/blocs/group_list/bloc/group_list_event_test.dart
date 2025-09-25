import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/group_list/group_list.dart';

void main() {
  group(GroupListEvent, () {
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
        expect(event1, isA<GroupListEvent>());
        expect(event1, isA<InitialFetch>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = InitialFetch();
        expect(event, isA<GroupListEvent>());
        GroupListEvent abstractEvent = event;
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
        expect(event1, isA<GroupListEvent>());
        expect(event1, isA<FetchMore>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = FetchMore();
        expect(event, isA<GroupListEvent>());
        GroupListEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(FetchGroups, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const FetchGroups(),
          equals(const FetchGroups()),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const FetchGroups().props,
          [],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = FetchGroups();
        // ignore: prefer_const_constructors
        final event2 = FetchGroups();

        expect(event1, equals(event2));
        expect(event1, isA<GroupListEvent>());
        expect(event1, isA<FetchGroups>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = FetchGroups();
        expect(event, isA<GroupListEvent>());
        GroupListEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(SearchGroup, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const SearchGroup('test search'),
          equals(const SearchGroup('test search')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const SearchGroup('test search').props,
          ['test search'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = SearchGroup('test search');
        // ignore: prefer_const_constructors
        final event2 = SearchGroup('test search');

        expect(event1, equals(event2));
        expect(event1, isA<GroupListEvent>());
        expect(event1, isA<SearchGroup>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = SearchGroup('test search');
        expect(event, isA<GroupListEvent>());
        GroupListEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group(ClearSearch, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const ClearSearch(),
          equals(const ClearSearch()),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const ClearSearch().props,
          [],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = ClearSearch();
        // ignore: prefer_const_constructors
        final event2 = ClearSearch();

        expect(event1, equals(event2));
        expect(event1, isA<GroupListEvent>());
        expect(event1, isA<ClearSearch>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = ClearSearch();
        expect(event, isA<GroupListEvent>());
        GroupListEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
