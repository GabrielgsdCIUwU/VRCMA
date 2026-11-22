import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/error/domain_exception.dart';

/// Base class for handling application errors.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Represents errors coming from the VRChat API.
class ApiFailure extends Failure {
  const ApiFailure(super.message);
}

// Represents errors coming from the local database.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class TwoFactorRequiredFailure extends Failure {
  final List<String> methods;
  const TwoFactorRequiredFailure(this.methods) : super('2FA required');

  @override
  List<Object?> get props => [message, methods];
}


class RateLimitFailure extends Failure {
  final int retryAfterMinutes;
  const RateLimitFailure(this.retryAfterMinutes)
      : super('Rate limit exceeded. Retry after $retryAfterMinutes minutes.');
  
  @override
  List<Object?> get props => [message, retryAfterMinutes];
}

class SyncFailure extends Failure {
  const SyncFailure(super.message);
}

class NetworkTimeoutFailure extends Failure {
  const NetworkTimeoutFailure([super.message = 'Connection timed out. Check your internet connection.']);
}

class DomainFailure extends Failure {
  final DomainException exception;

  DomainFailure(this.exception) : super(exception.defaultMessage);

  @override
  List<Object?> get props => [message, exception];
}