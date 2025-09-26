import 'package:gift_grab_client/presentation/extensions/string_extensions.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String getMonthsDayRange() {
    final lastDay = DateTime(this.year, this.month + 1, 0);

    final monthFormat = DateFormat('MMMM');
    final monthName = monthFormat.format(this);

    return '$monthName 1st - ${lastDay.day.toString().ordinal}';
  }
}
