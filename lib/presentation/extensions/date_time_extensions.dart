import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';

extension DateTimeL10n on DateTime {
  /// Returns a localized relative time representation (e.g., "Just now", "5 minutes ago").
  String toRelativeString(BuildContext context) {
    final l10n = context.l10n;
    final duration = DateTime.now().difference(this);

    if (duration.inMinutes < 1) return l10n.timeJustNow;
    if (duration.inMinutes < 60) return l10n.timeMinutesAgo(duration.inMinutes);
    if (duration.inHours < 24) return l10n.timeHoursAgo(duration.inHours);
    if (duration.inDays < 7) return l10n.timeDaysAgo(duration.inDays);

    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMd(locale).format(this);
  }
}

extension WeekdayL10n on int {
  /// Translates an ISO weekday index (1-7) to its localized short name.
  String toLocalizedWeekdayName(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final referenceDate = DateTime(2026, 6, this);
    return DateFormat.E(locale).format(referenceDate);
  }
}