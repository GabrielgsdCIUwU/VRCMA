import 'package:vrcma/data/services/battery/battery_service_factory.dart';
import 'package:vrcma/domain/services/i_battery_service.dart';

class BatteryService implements IBatteryService {
  late final IBatteryService _strategy;

  BatteryService() {
    _strategy = BatteryServiceFactory.create();
  }

  @override
  Future<int> getBatteryLevel() => _strategy.getBatteryLevel();

  @override
  Future<bool> isCharging() => _strategy.isCharging();
}