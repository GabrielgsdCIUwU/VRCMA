import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vrcma/core/di/network_repository_provider.dart';
import 'package:vrcma/core/l10n/arb/app_localizations.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/core/di/usecase_provider.dart';

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
  
  final prefs = await SharedPreferences.getInstance();
  final String languageCode = prefs.getString('selected_locale_code') ?? 'en';
  final l10n = await AppLocalizations.delegate.load(Locale(languageCode));

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: l10n.bgInitialNotificationTitle,
      initialNotificationContent: l10n.bgInitialNotificationContent,
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
  
  final container = ProviderContainer();

  final subApi = container.listen(vrcApiProvider, (_, _) {});
  final subRepo = container.listen(automationRepositoryProvider, (_, _) {});
  final subProc = container.listen(automationProcessorProvider, (_, _) {});
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final String languageCode = prefs.getString('selected_locale_code') ?? 'en';
    final l10n = await AppLocalizations.delegate.load(Locale(languageCode));

    final api = await container.read(vrcApiProvider.future);
    final userResponse = await api.rawApi.getAuthenticationApi().getCurrentUser();
    
    if (userResponse.data == null) {
      service.stopSelf();
      return;
    }
    
    final automationRepo = await container.read(automationRepositoryProvider.future);
    final processor = await container.read(automationProcessorProvider.future);
    
    api.streaming.start();
    
    final subscription = automationRepo.watchAutomationEvents().listen((event) async {
      try {
        await processor.process(event);
        
        if (service is AndroidServiceInstance) {
          final String senderName = event is IncomingUserEvent
            ? event.senderName
            : 'System';
          
          service.setForegroundNotificationInfo(
            title: l10n.bgNotificationTitle,
            content: l10n.bgNotificationContent(senderName),
          );
        }

        service.invoke('update_ui');

      } catch (e) {
        debugPrint("BG Error processing invitation: $e");
      }
    });


    service.on('stopService').listen((event) {
      subscription.cancel();
      api.streaming.stop();
      subApi.close();
      subRepo.close();
      subProc.close();
      container.dispose();
      service.stopSelf();
    });

  } catch (e, stackTrace) {
    debugPrint("BG Service Init Error: $e\n$stackTrace");
    service.stopSelf();
  }
}