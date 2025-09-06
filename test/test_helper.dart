import 'package:gift_grab_client/main.dart' as _;
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

class MockLogger extends Mock implements Logger {}

void initializeTestLogger() => _.logger = MockLogger();
