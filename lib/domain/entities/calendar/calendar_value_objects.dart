import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/calendar/enums/instance_region.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/error/calendar_domain_exception.dart';

/// Value object representing a validated VRChat world identifier.
class WorldId extends Equatable {
  final String value;

  const WorldId._(this.value);

  /// Validates and constructs a [WorldId]
  factory WorldId(String rawValue) {
    final trimmedValue = rawValue.trim();
    if (trimmedValue.isEmpty || !trimmedValue.startsWith('wrld_')) {
      throw CalendarDomainException(InvalidWorldIdError(trimmedValue));
    }
    return WorldId._(trimmedValue);
  }

  @override
  List<Object?> get props => [value];
}

/// Value object storing the schedule details associated with a timezone.
class TimezoneSchedule extends Equatable {
  final TimeOfDayValue startTime;
  final int durationMinutes;
  final String timezoneIana; // e.g., "Europe/Madrid"
  final DateTime? startDate;
  final DateTime? endDate;

  TimezoneSchedule({
    required this.startTime,
    required this.durationMinutes,
    required this.timezoneIana,
    this.startDate,
    this.endDate,
  }) {
    if (timezoneIana.trim().isEmpty) {
      throw CalendarDomainException(InvalidTimezoneError(timezoneIana));
    }
    if (durationMinutes <= 0) {
      throw CalendarDomainException(InvalidDurationError(durationMinutes));
    }
    if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
      throw CalendarDomainException(InvalidDurationError(-1));
    }
  }

  TimezoneSchedule copyWith({
    TimeOfDayValue? startTime,
    int? durationMinutes,
    String? timezoneIana,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TimezoneSchedule(
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      timezoneIana: timezoneIana ?? this.timezoneIana,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }


  @override
  List<Object?> get props => [startTime, durationMinutes, timezoneIana, startDate, endDate];
}

/// Value object representing the logic configuration for recurrent intervals.
class RecurrencePattern extends Equatable {
  final RecurrenceType type;
  final List<int> daysOfWeek;
  final List<int> daysOfMonth;

  const RecurrencePattern({
    required this.type,
    this.daysOfWeek = const [],
    this.daysOfMonth = const [],
  });

  @override
  List<Object?> get props => [type, daysOfWeek, daysOfMonth];
}

/// Value object representing the VRChat target instance configuration.
class InstanceLinkTemplate extends Equatable {
  final WorldId worldId;
  final InstanceAccessType accessType;
  final InstanceRegion region;

  const InstanceLinkTemplate({
    required this.worldId,
    required this.accessType,
    required this.region,
  });

  @override
  List<Object?> get props => [worldId, accessType, region];
}

/// Value Object representing mathematical numeric sequence increments.
class IncrementalConfig extends Equatable {
  final bool isEnabled;
  final int startValue;
  final int stepValue;
  final int currentValue;

  IncrementalConfig({
    required this.isEnabled,
    this.startValue = 1,
    this.stepValue = 1,
    this.currentValue = 1,
  }) {
    if (currentValue < 0) {
      throw CalendarDomainException(OutOfBoundsIncrementError(currentValue));
    }

    if (stepValue <= 0) {
      throw CalendarDomainException(InvalidDurationError(-1));
    }
  }

  IncrementalConfig next() {
    if (!isEnabled) return this;
    return IncrementalConfig(
      isEnabled: isEnabled,
      startValue: startValue,
      stepValue: stepValue,
      currentValue: currentValue + stepValue,
    );
  }

  @override
  List<Object?> get props => [isEnabled, startValue, stepValue, currentValue];
}

/// Value object representing a 24hour clock time (HH:mm) without timezone ambiguity.
class TimeOfDayValue extends Equatable implements Comparable<TimeOfDayValue> {
  final int hour;
  final int minute;

  const TimeOfDayValue._({
    required this.hour,
    required this.minute,
  });

  factory TimeOfDayValue({int hour = 0, int minute = 0}) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw CalendarDomainException(
        InvalidTimeFormatError('$hour$minute'),
      );
    }
    return TimeOfDayValue._(hour: hour, minute: minute);
  }

  factory TimeOfDayValue.parse(String formatted) {
    final parsed = tryParse(formatted);
    if (parsed == null) {
      throw CalendarDomainException(InvalidTimeFormatError(formatted));
    }
    return parsed;
  }

  static TimeOfDayValue? tryParse(String? formatted) {
    if (formatted == null || formatted.trim().isEmpty) return null;

    final parts = formatted.split(':');
    if (parts.length != 2) return const TimeOfDayValue._(hour: 0, minute: 0);
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
     if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return TimeOfDayValue._(hour: hour, minute: minute);
  }

  int get totalMinutes => hour * 60 + minute;

  String get formatted => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  TimeOfDayValue addMinutes(int minutesToAdd) {
    final newTotal = (totalMinutes + minutesToAdd) % (24 * 60);
    return TimeOfDayValue._(hour: newTotal ~/ 60, minute: newTotal % 60);
  }

  int minutesDifference(TimeOfDayValue other) {
    var diff = other.totalMinutes - totalMinutes;
    if (diff < 0) diff += 24 * 60;
    return diff;
  }

  @override
  int compareTo(TimeOfDayValue other) => totalMinutes.compareTo(other.totalMinutes);

  @override
  List<Object?> get props => [hour, minute];

  @override
  String toString() => formatted;
}