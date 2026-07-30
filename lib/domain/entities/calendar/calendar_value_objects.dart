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

  final String startTimeOfDay; // Format "HH:MM"
  final int durationMinutes;
  final String timezoneIana; // e.g., "Europe/Madrid"
  final DateTime? startDate;
  final DateTime? endDate;

  TimezoneSchedule({
    required this.startTimeOfDay,
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

  @override
  List<Object?> get props => [startTimeOfDay, durationMinutes, timezoneIana, startDate, endDate];
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