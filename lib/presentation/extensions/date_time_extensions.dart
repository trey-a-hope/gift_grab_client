import 'package:gift_grab_client/presentation/extensions/string_extensions.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String getMonthsDayRange() {
    final lastDay = DateTime(this.year, this.month + 1, 0);

    final monthFormat = DateFormat('MMMM');
    final monthName = monthFormat.format(this);

    return '$monthName 1st - ${lastDay.day.toString().ordinal}';
  }

  String MMM_d_y_h_mm_a() => DateFormat('MMM d, y h:mm a').format(toLocal());
  String MMM_d_y() => DateFormat('MMM d, y').format(toLocal());
  String h_mm_a() => DateFormat('h:mm a').format(toLocal());
}
