import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';

enum AutomationTrigger {
  newFriend,
  hasTag
}

class RoleAutomation extends Equatable {
  final int? id;
  final List<Role> roles;
  final AutomationTrigger trigger;
  final String? targetValue;

  const RoleAutomation({
    this.id,
    required this.roles,
    required this.trigger,
    this.targetValue,
  });

  RoleAutomation copyWith({
    int? id,
    List<Role>? roles,
    AutomationTrigger? trigger,
    String? targetValue,
  }) {
    return RoleAutomation(
      id: id ?? this.id,
      roles: roles ?? this.roles,
      trigger: trigger ?? this.trigger,
      targetValue: targetValue ?? this.targetValue,
    );
  }

  @override
  List<Object?> get props => [id, roles, trigger, targetValue];
}