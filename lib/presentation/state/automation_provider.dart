import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/data/repositories/automation_repository_imp.dart';
import 'package:vrcma/domain/usecases/automation/automation_processor.dart';
import 'package:vrcma/domain/usecases/automation/message_slot_manager.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/background_service_provider.dart';
import 'package:vrcma/presentation/state/friends_provider.dart';
import 'package:vrcma/presentation/state/logs_provider.dart';

part 'automation_provider.g.dart';

@riverpod
class AutomationState extends _$AutomationState {
  StreamSubscription? _vrcSubscription;
  StreamSubscription? _bgSubscription;
  @override
  void build() {
    ref.keepAlive();
    _init();
    
    ref.onDispose(() {
      _vrcSubscription?.cancel();
      _bgSubscription?.cancel();
    });
  }
  
  Future<void> _init() async {
    _bgSubscription = FlutterBackgroundService().on('update_ui').listen((event) {
      debugPrint("UI: Refreshing data...");
      ref.invalidate(automationLogsProvider);
      ref.invalidate(friendsListProvider);
    });
    
    if (Platform.isAndroid || Platform.isIOS) {
      final isBgEnabled = await ref.watch(backgroundServiceToggleProvider.future);
      if (isBgEnabled) {
        debugPrint("UI: Yielding WebSocket control to Background Service.");
        return;
      }
    }
    debugPrint("UI: Taking control of Websocket.");
    final api = await ref.watch(vrcApiProvider.future);
    api.streaming.start();
    
    final automationRepo = await ref.watch(automationRepositoryProvider.future);
    final processor = await ref.watch(automationProcessorProvider.future);
    
    _vrcSubscription = automationRepo.watchInvitations().listen((invitation) async {
      try {
        await processor.process(invitation);  
        ref.invalidate(automationLogsProvider);
      } catch (e) {
        debugPrint("Error processing invitation on loop: $e");
      }
      
    }, onError: (error) {
      debugPrint("Critical error!: $error");
    }, cancelOnError: false
    );
  }
}