extension StringExtensions on String {
  String get ordinalSuffix {
    final number = int.tryParse(this);

    if (number == null || number <= 0) return 'th';

    if (number % 100 >= 11 && number % 100 <= 13) {
      return 'th';
    }

    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String get ordinal => '$this$ordinalSuffix';
}

extension NullableStringExtensions on String? {
  String? get nullIfEmpty => (this?.isNotEmpty ?? false) ? this : null;
}
