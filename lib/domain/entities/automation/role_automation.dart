import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/error/domain_exception.dart';

enum AutomationTrigger {
  newFriend,
  hasTag
}

class RoleAutomation extends Equatable {
  final int? id;
  final List<Role> roles;
  final AutomationTrigger trigger;
  final String? targetValue;

  RoleAutomation({
    this.id,
    required this.roles,
    required this.trigger,
    this.targetValue,
  }) {
    if (roles.isEmpty) {
      throw RoleAutomationValidationException(
        const EmptyRoleAssignmentError(),
      );
    }

    if (trigger == AutomationTrigger.hasTag && (targetValue == null || targetValue!.trim().isEmpty)) {
      throw RoleAutomationValidationException(
        const MissingTriggerTagError()
      );
    }
  }

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