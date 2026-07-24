import 'package:equatable/equatable.dart';

/// Log entity recording successfully created VRChat API calendar instances.
class CalendarOccurrenceRun extends Equatable {
  final int? id;
  final int? automationId;
  final DateTime calculatedOccurrenceUtc;
  final String createdVrcEventId;
  final DateTime publishedAt;

  const CalendarOccurrenceRun({
    this.id,
    this.automationId,
    required this.calculatedOccurrenceUtc,
    required this.createdVrcEventId,
    required this.publishedAt
  });

  @override
  List<Object?> get props => [id, automationId, calculatedOccurrenceUtc, createdVrcEventId, publishedAt];
}