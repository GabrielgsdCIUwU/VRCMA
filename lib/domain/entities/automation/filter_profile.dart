import 'package:equatable/equatable.dart';

class Role extends Equatable {
  final int id;
  final String name;
  const Role({required this.id, required this.name});
  @override List<Object?> get props => [id, name];
}

enum RuleAction { accept, reject }

class ProfileRule extends Equatable {
  final int id;
  final Role role;
  final int priority;
  final RuleAction action;
  final int? fallbackGroup;

  const ProfileRule({
    required this.id,
    required this.role,
    required this.priority,
    required this.action,
    this.fallbackGroup,
  });

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

  @override List<Object?> get props => [id, name, isActive, rules, defaultRole];

}