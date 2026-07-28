import 'package:equatable/equatable.dart';

/// Entity representing exceptional modifications to a specific occurence date.
class CalendarException extends Equatable {
  final int? id;
  final int? automationId;
  final DateTime exceptionDate;
  final DateTime? exceptionEndDate;
  final bool isCancelled;
  final String? rescheduledTime;
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

  @override
  List<Object?> get props => [id, automationId, exceptionDate, exceptionEndDate, isCancelled, rescheduledTime, titleOverride];
}