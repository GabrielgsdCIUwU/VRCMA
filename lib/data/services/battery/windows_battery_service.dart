import 'dart:io';

import 'package:vrcma/domain/services/i_battery_service.dart';

class WindowsBatteryService implements IBatteryService {
  @override
  Future<int> getBatteryLevel() async {
    try {
      final result = await Process.run(
        'wmic',
        ['Path', 'Win32_Battery', 'Get', 'EstimatedChargeRemaining', '/Value'],
      );
      if (result.exitCode != 0) return 100;

      final output = result.stdout.toString();
      final match = RegExp(r'EstimatedChargeRemaining=(\d+)').firstMatch(output);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '100') ?? 100;
      }
    } catch (_) {}
    return 100;
  }

  @override
  Future<bool> isCharging() async {
    try {
      final result = await Process.run(
        'wmic',
        ['Path', 'Win32_Battery', 'Get', 'BatteryStatus', '/Value'],
      );
      if (result.exitCode != 0) return false;

      final output = result.stdout.toString();
       final match = RegExp(r'BatteryStatus=(\d+)').firstMatch(output);
      if (match != null) {
        final status = int.tryParse(match.group(1) ?? '1');
        return status == 2;
      }
    } catch (_) {}
    return false;
  }
}