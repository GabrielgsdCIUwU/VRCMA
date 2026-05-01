import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

const notificationChannelId = 'vrcma_automation_channel';
const notificationId = 888;

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'VRCMA Automation Service',
    description: 'Keeps VRChat automation running in the background.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'VRCMA Automation',
      initialNotificationContent: 'Running in background...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onBackgroundStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onBackgroundStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  
  final container = ProviderContainer();
  
  try {
    final api = await container.read(vrcApiProvider.future);
    final userResponse = await api.rawApi.getAuthenticationApi().getCurrentUser();
    
    if (userResponse.data == null) {
      service.stopSelf();
      return;
    }
    
    final automationRepo = await container.read(automationRepositoryProvider.future);
    final processor = await container.read(automationProcessorProvider.future);
    
    api.streaming.start();
    
    final subscription = automationRepo.watchInvitations().listen((invitation) async {
      try {
        await processor.process(invitation);
        
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'VRCMA Automation',
            content: 'Last processed: ${invitation.senderName}',
          );
        }
      } catch (e) {
        debugPrint("Background Error processing invitation $e");
      }
    });
    
    service.on('stopService').listen((event) {
      subscription.cancel();
      api.streaming.stop();
      container.dispose();
      service.stopSelf();
    });
  } catch (e) {
    debugPrint("Background Service Init Error: $e");
    service.stopSelf();
  }
}