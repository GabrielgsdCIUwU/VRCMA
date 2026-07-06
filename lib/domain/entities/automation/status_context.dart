import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';

/// Captures the current environment state to evaluate status rules.
class StatusContext extends Equatable {
  final String worldName;
  final String worldId;
  final int population;
  final InstanceAccessType instanceType;
  final int batteryLevel;
  final bool isCharging;
  final DateTime timestamp;
  final List<String> presentFriendIds;

  const StatusContext({
    required this.worldName,
    required this.worldId,
    required this.population,
    required this.instanceType,
    required this.batteryLevel,
    required this.isCharging,
    required this.timestamp,
    this.presentFriendIds = const [],
  });

  @override
  List<Object?> get props => [
    worldName, worldId, population, instanceType,
    batteryLevel, isCharging, timestamp, presentFriendIds
  ];
}
