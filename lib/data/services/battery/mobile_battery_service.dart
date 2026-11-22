import 'package:flutter/services.dart';
import 'package:vrcma/domain/services/i_battery_service.dart';

class MobileBatteryService implements IBatteryService {
  static const MethodChannel _channel = MethodChannel('vrcma/hardware_telemetry');

  @override
  Future<int> getBatteryLevel() async {
    try {
      final int? level = await _channel.invokeMethod<int>('getBatteryLevel');
      return level ?? 100;
    } on PlatformException {
      return 100;
    }
  }

  @override
  Future<bool> isCharging() async {
    try {
      final bool? charging = await _channel.invokeMethod<bool>('isCharging');
      return charging ?? false;
    } on PlatformException {
      return false;
    }
  }
}