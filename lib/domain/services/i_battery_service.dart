/// Interface defining the contract for retrieving device hardware telemetry.
abstract class IBatteryService {
  /// Retrieves the current battery level (0-100).
  Future<int> getBatteryLevel();

  /// Determines if the system is currently plugged into AC power and charging.
  Future<bool> isCharging();
}