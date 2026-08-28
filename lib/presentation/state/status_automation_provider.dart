import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/core/di/usecase_provider.dart';
import 'package:vrcma/core/services/battery/battery_service.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/automation/status_context.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/services/status_signal_manager.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/friends_provider.dart';
import 'package:vrcma/presentation/state/world_cache_provider.dart';

part 'status_automation_provider.g.dart';

@riverpod
class StatusAutomationOrchestrator extends _$StatusAutomationOrchestrator {
  StatusSignalManager? _signalManager;
  StreamSubscription? _signalSubscription;
  StreamSubscription? _overrideSubscription;

  bool _internalUpdatePending = false;

  DateTime _lastExecuteTime = DateTime.fromMillisecondsSinceEpoch(0);

  static const Duration _safetyCooldown = Duration(minutes: 5);

  @override
  FutureOr<void> build() async {
    ref.keepAlive();

    ref.listen(authStateProvider, (prev, next) {
      if (next.value == null) {
        _shutdown();
      } else {
        _startup();
      }
    });

    ref.onDispose(() {
      _shutdown();
    });

    _startup();
  }

  void _startup() async {
    _shutdown();

    final api = await ref.watch(vrcApiProvider.future);
    _signalManager = StatusSignalManager(api);

    final statusRepo = await ref.read(statusRepositoryProvider.future);
    final profiles = await statusRepo.getStatusProfiles();
    final activeProfile = profiles.firstWhere(
      (p) => p.isActive,
      orElse: () => const StatusProfile(name: "", fallbackStatus: StatusType.active),
    );

    if (activeProfile.id == null) return;

    _signalManager!.setupSignalsForProfile(activeProfile);

    _signalSubscription = _signalManager!.signals.listen((signal) async {
      await triggerEvaluation(activeProfile);
    });

    _overrideSubscription = api.streaming.vrcEventStream.listen((event) async {
      if (event is UserUpdateEvent) {
        final currentUser = event.user;
        await _handleManualOverrideProtection(currentUser, activeProfile);
      }
    });
  }

  void _shutdown() {
    _signalSubscription?.cancel();
    _signalSubscription = null;
    _overrideSubscription?.cancel();
    _overrideSubscription = null;
    _signalManager?.dispose();
    _signalManager = null;
  }

  Future<void> _handleManualOverrideProtection(StreamedCurrentUser remoteUser, StatusProfile activeProfile) async {
    final statusRepo = await ref.read(statusRepositoryProvider.future);
    
    final String currentStatus = remoteUser.status.value;
    final String currentDescription = remoteUser.statusDescription;

    final String lastAppliedStatus = activeProfile.lastAppliedStatus?.apiValue ?? '';
    final String lastAppliedDescription = activeProfile.lastAppliedMessage ?? '';

    if (lastAppliedStatus.isEmpty) return;

    final bool statusMismatched = currentStatus != lastAppliedStatus;
    final bool descriptionMismatched = currentDescription != lastAppliedDescription;

    if (statusMismatched || descriptionMismatched) {
      if (_internalUpdatePending) {
        _internalUpdatePending = false;
        debugPrint('ManualOverride: Verified automated transition safely.');
        return;
      }

      debugPrint('ManualOverride: Mismatch detected. Current: ($currentStatus, $currentDescription) vs Applied: ($lastAppliedStatus, $lastAppliedDescription)');

      await statusRepo.setProfileActive(activeProfile.id!, false);
      _shutdown();
    }
  }

  Future<void> triggerEvaluation(StatusProfile activeProfile) async {
    final now = DateTime.now();
    if (now.difference(_lastExecuteTime) < _safetyCooldown) return;

    final api = await ref.read(vrcApiProvider.future);
    
    final currentUserResponse = await api.rawApi.getAuthenticationApi().getCurrentUser();
    final currentUser = currentUserResponse.data;

    if (currentUser == null) return;

    final context = await _buildStatusContext(currentUser);

    final coordinator = await ref.read(coordinateStatusAutomationUseCaseProvider.future);

    final evaluation = await ref.read(evaluateStatusUseCaseProvider.future).then(
      (useCase) => useCase.execute(profile: activeProfile, context: context),
    );

    final bool statusChanged = activeProfile.lastAppliedStatus != evaluation.status;
    final bool messageChanged = activeProfile.lastAppliedMessage != evaluation.message;

    if (!statusChanged && !messageChanged) {
      return;
    }

    _internalUpdatePending = true;

    final result = await coordinator.execute(
      activeProfile: activeProfile,
      currentContext: context,
    );

    result.fold(
      (failure) {
        _internalUpdatePending = false;
        debugPrint("Error executing remote status change: ${failure.message}");
      },
      (_) {
        _lastExecuteTime = DateTime.now();
      }
    );
  }

  Future<StatusContext> _buildStatusContext(CurrentUser user) async {
    final batteryService = BatteryService();
    final batteryLevel = await batteryService.getBatteryLevel();
    final charging = await batteryService.isCharging();

    final presence = user.presence;
    final String rawLocation = presence?.world ?? "";

    final parsedInstance = VrcInstance.parse(rawLocation);
    String worldName = "Unknown World";

    if (parsedInstance.isResolvableWorld && parsedInstance.worldId != null) {
      worldName = await ref.read(worldNameProvider(parsedInstance.worldId!).future);
    }

    final friends = await ref.read(friendsListProvider.future);
    final List<String> presentFriendIds = [];
    final List<String> presentFriendNames = [];

    for (final friend in friends) {
      if (friend.location == rawLocation && rawLocation.isNotEmpty) {
        presentFriendIds.add(friend.id);
        presentFriendNames.add(friend.displayName);
      }
    }

    return StatusContext(
      worldName: worldName,
      worldId: parsedInstance.worldId ?? "",
      population: presence?.instance?.length ?? 1,
      instanceType: parsedInstance.accessType,
      batteryLevel: batteryLevel,
      isCharging: charging,
      timestamp: DateTime.now(),
      presentFriendIds: presentFriendIds,
      presentFriendNames: presentFriendNames,
    );
  }
}