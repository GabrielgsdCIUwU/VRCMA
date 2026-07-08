import 'dart:io';

import 'package:vrcma/domain/services/i_battery_service.dart';

class LinuxBatteryService implements IBatteryService {
  String? _cachedPath;

  /// Discovers the path where battery telemetry is located.
  String _getBatteryPath() {
    if (_cachedPath != null) return _cachedPath!;

    final prefixes = ['BAT0', 'BAT1', 'battery'];
    for (final prefix in prefixes) {
      final path = '/sys/class/power_supply/$prefix';
      if (Directory(path).existsSync()) {
        _cachedPath = path;
        return path;
      }
    }
    _cachedPath = '';
    return '';
  }

  @override
  Future<int> getBatteryLevel() async {
    final path = _getBatteryPath();
    if (path.isEmpty) return 100;

    try {
      final capacityFile = File("$path/capacity");
      if (await capacityFile.exists()) {
        final content = await capacityFile.readAsString();
        return int.tryParse(content.trim()) ?? 100;
      }
    } catch (_) {}
    return 100;
  }

  @override
  Future<bool> isCharging() async {
    final path = _getBatteryPath();
    if (path.isEmpty) return false;

    try {
      final statusFile = File("$path/status");
      if (await statusFile.exists()) {
        final content = await statusFile.readAsString();
        return content.trim().toLowerCase() == 'charging';
      }
    } catch (_) {}
    return false;
  }
}