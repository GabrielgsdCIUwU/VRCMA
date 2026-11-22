import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/calendar/enums/planned_occurrence_status.dart';

/// Pure planning projection of a single upcoming calendar occurrence.
///
/// Unlike [CalendarOccurrenceRun], which records persisted publication history,
/// this entity represents a runtime evaluation used both for scheduling and UI previews.
class PlannedOccurrence extends Equatable {
  final DateTime startUtc;
  final PlannedOccurrenceStatus status;
  final String? titleOverride;
  final String? existingRemoteEventId;

  const PlannedOccurrence({
    required this.startUtc,
    required this.status,
    this.titleOverride,
    this.existingRemoteEventId,
  });

  @override
  List<Object?> get props => [
    startUtc,
    status,
    titleOverride,
    existingRemoteEventId,
  ];
}