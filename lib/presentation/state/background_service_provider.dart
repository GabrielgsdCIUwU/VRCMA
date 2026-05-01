import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'background_service_provider.g.dart';

@riverpod
class BackgroundServiceToggle extends _$BackgroundServiceToggle {
  @override
  FutureOr<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('bg_automation_enabled') ?? false;
    
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    
    if (isEnabled && !isRunning) {
      service.startService();
    } else if (!isEnabled && isRunning) {
      service.invoke('stopService');
    }
    
    return isEnabled;
  }
  
  Future<void> toggle(bool value) async {
    state = const AsyncLoading();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bg_automation_enabled', value);
    
    final service = FlutterBackgroundService();
    
    value ? await service.startService() : service.invoke('stopService');
    
    state = AsyncData(value);
  }
}