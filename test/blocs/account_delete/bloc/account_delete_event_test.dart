import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/account_delete/account_delete.dart';

void main() {
  group(AccountDeleteEvent, () {
    group(DeleteAccount, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(const DeleteAccount(), equals(const DeleteAccount()));
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const DeleteAccount().props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        final event1 = DeleteAccount(); // ignore: prefer_const_constructors
        final event2 = DeleteAccount(); // ignore: prefer_const_constructors

        expect(event1, equals(event2));
        expect(event1, isA<AccountDeleteEvent>());
        expect(event1, isA<DeleteAccount>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = DeleteAccount();
        expect(event, isA<AccountDeleteEvent>());
        AccountDeleteEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
