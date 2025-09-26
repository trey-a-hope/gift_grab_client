import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/test_descriptions.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/account_read.dart';

void main() {
  group(AccountReadEvent, () {
    group(ReadAccount, () {
      test(TestDescriptions.event.valueEqual, () {
        expect(const ReadAccount(), equals(const ReadAccount()));
      });

      test(TestDescriptions.event.propsEqual, () {
        expect(const ReadAccount().props, []);
      });

      test(TestDescriptions.event.correctInstance, () {
        final event1 = ReadAccount(); // ignore: prefer_const_constructors
        final event2 = ReadAccount(); // ignore: prefer_const_constructors

        expect(event1, equals(event2));
        expect(event1, isA<AccountReadEvent>());
        expect(event1, isA<ReadAccount>());
      });

      test(TestDescriptions.event.sealedClass, () {
        const event = ReadAccount();
        expect(event, isA<AccountReadEvent>());
        AccountReadEvent abstractEvent = event;
        expect(abstractEvent, equals(event));
      });
    });
  });
}
