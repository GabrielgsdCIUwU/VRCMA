import 'package:equatable/equatable.dart';

/// Lightweight domain representation of an event currently hosted on VRChat.
///
/// Used to reconcile local automation rules against events created manually
/// on the VRChat website or from another client.
class RemoteCalendarEvent extends Equatable {
  final String id;
  final String title;
  final DateTime startsAtUtc;
  final DateTime endsAtUtc;

  const RemoteCalendarEvent({
    required this.id,
    required this.title,
    required this.startsAtUtc,
    required this.endsAtUtc,
  });

  @override
  List<Object?> get props => [id, title, startsAtUtc, endsAtUtc];
}