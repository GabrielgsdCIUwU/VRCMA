import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';

class Role extends Equatable {
  final int id;
  final String name;
  const Role({required this.id, required this.name});
  @override List<Object?> get props => [id, name];
}

enum RuleAction { accept, reject }

class ProfileRule extends Equatable {
  final int? id;
  final Role role;
  final int priority;
  final RuleAction action;
  final int? fallbackGroup;
  final CustomMessage? message;

  const ProfileRule({
    this.id,
    required this.role,
    required this.priority,
    required this.action,
    this.fallbackGroup,
    this.message
  });
  
  ProfileRule copyWith({
    int? id,
    Role? role,
    int? priority,
    RuleAction? action,
    int? fallbackGroup,
    CustomMessage? message,
  }) {
    return ProfileRule(
      id: id?? this.id,
      role: role ?? this.role,
      priority: priority ?? this.priority,
      action: action ?? this.action,
      fallbackGroup: fallbackGroup ?? this.fallbackGroup,
      message: message ?? this.message,
    );
  }

  @override List<Object?> get props => [id, role, priority, action, fallbackGroup];
}

class FilterProfile extends Equatable{
  final int? id;
  final String name;
  final bool isActive;
  final List<ProfileRule> rules;
  final Role? defaultRole;

  const FilterProfile({
    this.id,
    required this.name,
    this.isActive = false,
    this.rules = const [],
    this.defaultRole,
  });
  
  FilterProfile copyWith({
    int? id,
    String? name,
    bool? isActive,
    List<ProfileRule>? rules,
    Role? defaultRole,
  }) {
    return FilterProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      rules: rules ?? this.rules,
      defaultRole: defaultRole ?? this.defaultRole,
    );
  }

  @override List<Object?> get props => [id, name, isActive, rules, defaultRole];

}