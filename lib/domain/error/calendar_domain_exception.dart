import 'package:vrcma/domain/error/domain_exception.dart';

/// Represents validation errors for calendar domain aggregates.
sealed class CalendarValidationError {
  String get errorCode;
  String get defaultMessage;
  const CalendarValidationError();
}

class InvalidWorldIdError extends CalendarValidationError {
  final String providedId;
  const InvalidWorldIdError(this.providedId);

  @override
  String get errorCode => 'CAL_WORLD_ID_INVALID';

  @override
  String get defaultMessage => 'The world ID "$providedId" is structurally invalid. It must start with "wrld_".';
}

class InvalidTimezoneError extends CalendarValidationError {
  final String timezone;
  const InvalidTimezoneError(this.timezone);

  @override
  String get errorCode => 'CAL_TIMEZONE_INVALID';

  @override
  String get defaultMessage => 'The provided timezone "$timezone" is empty or structurally invalid.';
}

class InvalidDurationError extends CalendarValidationError {
  final int duration;
  const InvalidDurationError(this.duration);

  @override
  String get errorCode => 'CAL_DURATION_INVALID';

  @override
  String get defaultMessage => 'The duration must be a positive integer greater than zero. Provided: $duration.';
}

class OutOfBoundsIncrementError extends CalendarValidationError {
  final int value;
  const OutOfBoundsIncrementError(this.value);

  @override
  String get errorCode => 'CAL_INCREMENT_OUT_OF_BOUNDS';

  @override
  String get defaultMessage => 'The current increment value ($value) cannot be negative.';
}

class WorldIdPatternValidationError extends CalendarValidationError {
  const WorldIdPatternValidationError();

  @override
  String get errorCode => 'WORLD_ID_PATTERN_INVALID';

  @override
  String get defaultMessage => 'The provided World ID pattern is invalid.';
}

class WorldIdValidationException extends DomainException {
  final WorldIdPatternValidationError error;

  WorldIdValidationException(this.error)
      : super(
          errorCode: error.errorCode,
          defaultMessage: error.defaultMessage,
        );
}

class CalendarPublishException extends DomainException {
  final String details;

  CalendarPublishException(this.details)
      : super(
          errorCode: 'CAL_PUBLISH_FAILED',
          defaultMessage: 'Failed to publish calendar event: $details',
        );
}

class CalendarDeleteException extends DomainException {
  final String details;

  CalendarDeleteException(this.details)
      : super(
          errorCode: 'CAL_DELETE_FAILED',
          defaultMessage: 'Failed to delete calendar event: $details',
        );
}

class CalendarPermissionsException extends DomainException {
  CalendarPermissionsException()
      : super(
          errorCode: 'CAL_PERMISSIONS_DENIED',
          defaultMessage: 'Insufficient permissions to manage calendar events in this group.',
        );
}

class CalendarDomainException extends DomainException {
  final CalendarValidationError error;
  CalendarDomainException(this.error)
    : super(
      errorCode: error.errorCode,
      defaultMessage: error.defaultMessage
    );
}