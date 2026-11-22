import 'dart:io';

import 'package:vrcma/data/services/battery/linux_battery_service.dart';
import 'package:vrcma/data/services/battery/mobile_battery_service.dart';
import 'package:vrcma/data/services/battery/windows_battery_service.dart';
import 'package:vrcma/domain/services/i_battery_service.dart';

class BatteryServiceFactory {
  static IBatteryService create() {
    if (Platform.isWindows) {
      return WindowsBatteryService();
    } else if (Platform.isLinux) {
      return LinuxBatteryService();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return MobileBatteryService();
    }
    return WindowsBatteryService();
  }
}