import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';

part 'background_service_provider.g.dart';

@riverpod
class BackgroundServiceToggle extends _$BackgroundServiceToggle {
  @override
  FutureOr<bool> build() async {
    final repo = await ref.watch(configurationRepositoryProvider.future);
    final isEnabled = await repo.getBool('bg_automation_enabled') ?? false;
    
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
    final repo = await ref.read(configurationRepositoryProvider.future);
    await repo.setBool('bg_automation_enabled', value);
    
    final service = FlutterBackgroundService();
    
    value ? await service.startService() : service.invoke('stopService');
    
    state = AsyncData(value);
  }
}