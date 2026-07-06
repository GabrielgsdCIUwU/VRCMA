import 'dart:io';

import 'package:vrcma/core/services/battery/linux_battery_service.dart';
import 'package:vrcma/core/services/battery/mobile_battery_service.dart';
import 'package:vrcma/core/services/battery/windows_battery_service.dart';
import 'package:vrcma/domain/services/i_battery_service.dart';

class BatteryService implements IBatteryService {
  late final IBatteryService _strategy;

  BatteryService() {
    if (Platform.isWindows) {
      _strategy = WindowsBatteryService();
    } else if (Platform.isLinux) {
      _strategy = LinuxBatteryService();
    } else if (Platform.isAndroid || Platform.isIOS) {
      _strategy = MobileBatteryService();
    } else {
      _strategy = WindowsBatteryService();
    }
  }

  @override
  Future<int> getBatteryLevel() => _strategy.getBatteryLevel();

  @override
  Future<bool> isCharging() => _strategy.isCharging();
}