import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';

/// Entity representing exceptional modifications to a specific occurrence date or date range.
class CalendarException extends Equatable {
  final int? id;
  final int? automationId;
  final DateTime exceptionDate;
  final DateTime? exceptionEndDate;
  final bool isCancelled;
  final TimeOfDayValue? rescheduledTime;
  final String? titleOverride;

  const CalendarException({
    this.id,
    this.automationId,
    required this.exceptionDate,
    this.exceptionEndDate,
    required this.isCancelled,
    this.rescheduledTime,
    this.titleOverride,
  });

  /// Returns a copy of this exception with selectively overridden fields.
  CalendarException copyWith({
    int? id,
    int? automationId,
    DateTime? exceptionDate,
    DateTime? Function()? exceptionEndDate,
    bool? isCancelled,
    TimeOfDayValue? Function()? rescheduledTime,
    String? Function()? titleOverride,
  }) {
    return CalendarException(
      id: id ?? this.id,
      automationId: automationId ?? this.automationId,
      exceptionDate: exceptionDate ?? this.exceptionDate,
      exceptionEndDate:
      exceptionEndDate != null ? exceptionEndDate() : this.exceptionEndDate,
      isCancelled: isCancelled ?? this.isCancelled,
      rescheduledTime:
      rescheduledTime != null ? rescheduledTime() : this.rescheduledTime,
      titleOverride:
      titleOverride != null ? titleOverride() : this.titleOverride,
    );
  }

  @override
  List<Object?> get props => [
    id,
    automationId,
    exceptionDate,
    exceptionEndDate,
    isCancelled,
    rescheduledTime,
    titleOverride,
  ];
}