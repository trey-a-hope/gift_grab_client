part of 'globals.dart';

class _TestDescriptions {
  final event = _EventDescriptions();
  final state = _StateDescriptions();
}

class _EventDescriptions {
  String get valueEqual => 'supports value equality';
  String get propsEqual => 'props are correct';
  String get diffProps => 'different event props are not equal';
}

class _StateDescriptions {
  String get initialValues => 'should have correct initial values';
  String get valueEquality => 'should support value equality';
  String get copyWithNoParams =>
      'returns same object when no properties are passed';
  String get copyWithPreserveState =>
      'copyWith should preserve existing values when no parameters provided';
  String get copyWithNewInstance =>
      'copyWith should return new instance with updated values';
  String get propsContains => 'props should contain all properties';
}
