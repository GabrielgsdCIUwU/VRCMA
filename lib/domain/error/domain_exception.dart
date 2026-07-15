/// Base class representing any business rule violation within the domain layer.
abstract class DomainException implements Exception {
  final String errorCode;
  final String defaultMessage;

  const DomainException({
    required this.errorCode,
    required this.defaultMessage,
  });

  @override
  String toString() => 'DomainException [$errorCode]: $defaultMessage';
}

/// Represents structural validation reasons for a VRChat world ID.
sealed class WorldIdValidationError {
  String get errorCode;
  String get defaultMessage;
  const WorldIdValidationError();
}

class WorldIdPatternValidationError extends WorldIdValidationError {
  final String providedId;
  const WorldIdPatternValidationError(this.providedId);

  @override
  String get errorCode => 'WORLD_ID_PATTERN_INVALID';

  @override
  String get defaultMessage => 'The world ID "$providedId" must start with "wrld_" and be at least 10 characters long.';
}

class WorldIdValidationException extends DomainException {
  final WorldIdValidationError error;
  WorldIdValidationException(this.error)
      : super(errorCode: error.errorCode, defaultMessage: error.defaultMessage);
}



/// Represents structural validation reasons for custom messages.
sealed class MessageValidationError {
  String get errorCode;
  String get defaultMessage;
  const MessageValidationError();
}

class MessageEmptyValidationError extends MessageValidationError {
  const MessageEmptyValidationError();

  @override
  String get errorCode => 'MESSAGE_EMPTY';

  @override
  String get defaultMessage => 'Message content cannot be empty.';
}

class MessageTooLongValidationError extends MessageValidationError {
  final int actualLength;
  final int maxLength;
  const MessageTooLongValidationError({required this.actualLength, required this.maxLength});

  @override
  String get errorCode => 'MESSAGE_TOO_LONG';

  @override
  String get defaultMessage => 'Message length of $actualLength exceeds the limit of $maxLength characters.';
}

class InvalidSlotIndexValidationError extends MessageValidationError {
  final int providedIndex;
  const InvalidSlotIndexValidationError(this.providedIndex);

  @override
  String get errorCode => 'MESSAGE_INVALID_SLOT_INDEX';

  @override
  String get defaultMessage => 'The slot index $providedIndex is invalid.';
}

class MessageValidationException extends DomainException {
  final MessageValidationError error;
  MessageValidationException(this.error)
      : super(errorCode: error.errorCode, defaultMessage: error.defaultMessage);
}

/// Represents validation reasons for profile rules configuration.
sealed class ProfileRuleValidationError {
  String get errorCode;
  String get defaultMessage;
  const ProfileRuleValidationError();
}

class RuleInviteMessageMismatchError extends ProfileRuleValidationError {
  final String actionName;
  final String messageTypeName;
  const RuleInviteMessageMismatchError({required this.actionName, required this.messageTypeName});

  @override
  String get errorCode => 'RULE_INVITE_MISMATCH';

  @override
  String get defaultMessage => 'Invite response message type "$messageTypeName" does not align with action "$actionName".';
}

class RuleRequestMessageMismatchError extends ProfileRuleValidationError {
  final String actionName;
  final String messageTypeName;
  const RuleRequestMessageMismatchError({required this.actionName, required this.messageTypeName});

  @override
  String get errorCode => 'RULE_REQUEST_MISMATCH';

  @override
  String get defaultMessage => 'Request response message type "$messageTypeName" does not align with action "$actionName".';
}

class ProfileRuleValidationException extends DomainException {
  final ProfileRuleValidationError error;
  ProfileRuleValidationException(this.error)
      : super(errorCode: error.errorCode, defaultMessage: error.defaultMessage);
}


/// Represents validation reasons for status conditions.
sealed class StatusRuleValidationError {
  String get errorCode;
  String get defaultMessage;
  const StatusRuleValidationError();
}

class InvalidStatusOperatorError extends StatusRuleValidationError {
  final String operatorName;
  final String conditionName;
  const InvalidStatusOperatorError({required this.operatorName, required this.conditionName});

  @override
  String get errorCode => 'STATUS_INVALID_OPERATOR';

  @override
  String get defaultMessage => 'Operator "$operatorName" is incompatible with condition "$conditionName".';
}

class EmptyStatusConditionValueError extends StatusRuleValidationError {
  const EmptyStatusConditionValueError();

  @override
  String get errorCode => 'STATUS_EMPTY_VALUE';

  @override
  String get defaultMessage => 'The threshold value of the status condition cannot be empty.';
}

class StatusRuleValidationException extends DomainException {
  final StatusRuleValidationError error;
  StatusRuleValidationException(this.error)
      : super(errorCode: error.errorCode, defaultMessage: error.defaultMessage);
}


/// Represents validation reasons for role automation.
sealed class RoleAutomationValidationError {
  String get errorCode;
  String get defaultMessage;
  const RoleAutomationValidationError();
}

class EmptyRoleAssignmentError extends RoleAutomationValidationError {
  const EmptyRoleAssignmentError();

  @override
  String get errorCode => 'ROLE_AUTO_EMPTY_ROLES';

  @override
  String get defaultMessage => 'At least one role must be configured for the automation rule.';
}

class MissingTriggerTagError extends RoleAutomationValidationError {
  const MissingTriggerTagError();

  @override
  String get errorCode => 'ROLE_AUTO_MISSING_TAG';

  @override
  String get defaultMessage => 'A target tag must be selected for tag-based trigger conditions.';
}

class RoleAutomationValidationException extends DomainException {
  final RoleAutomationValidationError error;
  RoleAutomationValidationException(this.error)
      : super(errorCode: error.errorCode, defaultMessage: error.defaultMessage);
}