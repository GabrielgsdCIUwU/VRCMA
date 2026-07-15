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

/// Thrown when a VRChat world ID pattern validation fails
class InvalidWorldIdException extends DomainException {
  const InvalidWorldIdException(String details)
    : super (
      errorCode: 'INVALID_WORD_ID',
      defaultMessage: 'Invalid VRChat world identifier pattern: $details',
    );
}

/// Thrown when message characteristics (length, content, slots) violate guidelines.
class MessageValidationException extends DomainException {
  const MessageValidationException(String subCode, String details)
    : super(
      errorCode: 'MESSAGE_$subCode',
      defaultMessage: 'Message validation failure: $details',
    );
}

/// Thrown when a rule attempts to link a message type inconsistent with its action context.
class RuleMessageMismatchException extends DomainException {
  const RuleMessageMismatchException(String subCode, String details)
    :super (
      errorCode: 'INVALID_RULE_OPERATOR',
      defaultMessage: 'Incompatible operator assigned: $details',
    );
}

/// Thrown when general parameter contraints within status conditions are violated.
class StatusRuleValidationException extends DomainException {
  const StatusRuleValidationException(String subCode, String details)
    : super (
      errorCode: 'STATUS_$subCode',
      defaultMessage: 'Status condition validation failed: $details',
    );
}

/// Thrown when role automation rules have invalid triggers or target values.
class RoleAutomationValidationException extends DomainException {
  const RoleAutomationValidationException(String subCode, String details)
    : super(
      errorCode: 'ROLE_AUTO_$subCode',
      defaultMessage: 'Role automation contraints violated: $details',
    );
}