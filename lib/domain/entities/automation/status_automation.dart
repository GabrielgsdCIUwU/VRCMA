import 'package:equatable/equatable.dart';

/// Represents the VRChat status colors/types.
enum StatusType {
  active,
  joinMe,
  askMe,
  busy;

  String get apiValue {
    switch (this) {
      case StatusType.active: return 'active';
      case StatusType.joinMe: return 'join me';
      case StatusType.askMe: return 'ask me';
      case StatusType.busy: return 'busy';
    }
  }

  static StatusType fromString(String value) {
    return StatusType.values.firstWhere(
      (e) => e.apiValue == value || e.name == value,
      orElse: () => StatusType.active
    );
  }
}

/// Types of conditions that can trigger a status change.
enum ConditionType {
  population,     //* Number of people in the instance
  instanceType,   //* Public, Friends+, Group...
  batteryLevel,   //* Device battery (Mobile only)
  friendPresent,  //* If a specific role or friend is in the same instance
  timeRange,      //* Specific hours of the day
  world,          //* Target world ID matching 
}

/// Comparison operators for rules.
enum RuleOperator {
  greaterThan,
  lessThan,
  equalTo,
  contains,
  between,
}

/// Dynamic restriction helper to tie variables with meaningful operators
extension ConditionTypeOperators on ConditionType {
  List<RuleOperator> get allowedOperators {
    switch (this) {
      case ConditionType.population:
      case ConditionType.batteryLevel:
        return [
          RuleOperator.greaterThan,
          RuleOperator.lessThan,
          RuleOperator.equalTo,
          RuleOperator.between,
        ];
      
      case ConditionType.timeRange:
        return [
          RuleOperator.between,
          RuleOperator.equalTo,
        ];
      
      case ConditionType.instanceType:
      case ConditionType.friendPresent:
        return [
          RuleOperator.equalTo,
        ];
      
      case ConditionType.world:
        return [
          RuleOperator.equalTo,
          RuleOperator.contains
        ];
    }
  }
}

/// A specific rule within a status profile.
class StatusRule extends Equatable {
  final int? id;
  final int priority;
  final StatusType targetStatus;
  final String? messageTemplate;
  final ConditionType conditionType;
  final RuleOperator operator;
  final String conditionValue;

  const StatusRule({
    this.id,
    required this.priority,
    required this.targetStatus,
    this.messageTemplate,
    required this.conditionType,
    required this.operator,
    required this.conditionValue,
  });

  @override
  List<Object?> get props => [id, priority, targetStatus, messageTemplate, conditionType, operator, conditionType];
}

/// A collection of rules that define a behaviour.
class StatusProfile extends Equatable {
  final int? id;
  final String name;
  final bool isActive;
  final StatusType fallbackStatus;
  final String? fallbackTemplate;
  final List<StatusRule> rules;

  final StatusType? lastAppliedStatus;
  final String? lastAppliedMessage;

  const StatusProfile({
    this.id,
    required this.name,
    this.isActive = false,
    required this.fallbackStatus,
    this.fallbackTemplate,
    this.rules = const [],
    this.lastAppliedStatus,
    this.lastAppliedMessage,
  });

  @override
  List<Object?> get props => [
    id, name, isActive, fallbackStatus, fallbackTemplate,
    rules, lastAppliedStatus, lastAppliedMessage
  ];

  StatusProfile copyWith({
    int? id,
    String? name,
    bool? isActive,
    StatusType? fallbackStatus,
    String? fallbackTemplate,
    List<StatusRule>? rules,
    StatusType? lastAppliedStatus,
    String? lastAppliedMessage,
  }) {
    return StatusProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      fallbackStatus: fallbackStatus ?? this.fallbackStatus,
      fallbackTemplate: fallbackTemplate ?? this.fallbackTemplate,
      rules: rules ?? this.rules,
      lastAppliedStatus: lastAppliedStatus ?? this.lastAppliedStatus,
      lastAppliedMessage: lastAppliedMessage ?? this.lastAppliedMessage
    );
  }
}