import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/user_list/user_list.dart';

void main() {
  group('UserListEvent', () {
    group('SearchUser', () {
      test(TestDescriptions.event.valueEqual, () {
        expect(
          const SearchUser('testUser'),
          equals(const SearchUser('testUser')),
        );
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(
          const SearchUser('testUser').props,
          ['testUser'],
        );
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = SearchUser('testUser');
        // ignore: prefer_const_constructors
        final event2 = SearchUser('testUser');

        expect(event1, equals(event2));
        expect(event1, isA<UserListEvent>());
        expect(event1, isA<SearchUser>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = SearchUser('testUser');
        expect(event, isA<UserListEvent>());
        UserListEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });

    group('ClearSearch', () {
      test(TestDescriptions.event.valueEqual, () {
        expect(const ClearSearch(), equals(const ClearSearch()));
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const ClearSearch().props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        // ignore: prefer_const_constructors
        final event1 = ClearSearch();
        // ignore: prefer_const_constructors
        final event2 = ClearSearch();

        expect(event1, equals(event2));
        expect(event1, isA<UserListEvent>());
        expect(event1, isA<ClearSearch>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = ClearSearch();
        expect(event, isA<UserListEvent>());
        UserListEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
