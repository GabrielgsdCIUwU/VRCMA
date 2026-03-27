/// Base class for handling application errors.
abstract class Failure {
  final String message;
  const Failure(this.message);
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
}