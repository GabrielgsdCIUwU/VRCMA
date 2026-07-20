import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class LocalizationHelpers {
  static String getLocalizedWeekdayName(BuildContext context, int weekday) {
    final locale = Localizations.localeOf(context).toString();

    final referenceDate = DateTime(2026, 6, weekday);
    return DateFormat.E(locale).format(referenceDate);
  }
}