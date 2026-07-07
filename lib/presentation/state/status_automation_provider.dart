import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/core/di/network_repository_provider.dart';
import 'package:vrcma/core/services/battery/battery_service.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/automation/status_context.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/usecases/automation/status/coordinate_status_automation_use_case.dart';
import 'package:vrcma/domain/usecases/automation/status/evaluate_status_use_case.dart';
import 'package:vrcma/domain/usecases/automation/status/matchers/status_condition_matcher.dart';
import 'package:vrcma/domain/usecases/automation/status/matchers/status_template_resolver.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/friends_provider.dart';
import 'package:vrcma/presentation/state/world_cache_provider.dart';

part 'status_automation_provider.g.dart';

@riverpod
class StatusAutomationOrchestrator extends _$StatusAutomationOrchestrator {
  Timer? _pollingTimer;
  StreamSubscription? _streamSubscription;
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

  void _startup() {
    _shutdown();

    _pollingTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      triggerEvaluation();
    });

    _listenToStreamingEvents();
  }

  void _shutdown() {
    _pollingTimer?.cancel();
    _streamSubscription?.cancel();
  }

  Future<void> _listenToStreamingEvents() async {
    final api  = await ref.watch(vrcApiProvider.future);

    _streamSubscription = api.streaming.vrcEventStream.listen((event) {
      if (event is UserUpdateEvent || event is UserLocationEvent) {
        triggerEvaluation();
      }
    });
  }

  Future<void> triggerEvaluation() async {
    final now = DateTime.now();
    if (now.difference(_lastExecuteTime) < _safetyCooldown) return;

    final statusRepo = await ref.read(statusRepositoryProvider.future);
    final profiles = await statusRepo.getStatusProfiles();
    final activeProfile = profiles.firstWhere(
      (p) => p.isActive,
      orElse: () => const StatusProfile(name: "", fallbackStatus: StatusType.active)
    );

    if (activeProfile.id == null) return;

    final api = await ref.read(vrcApiProvider.future);
    final currentUserResponse = await api.rawApi.getAuthenticationApi().getCurrentUser();
    final currentUser = currentUserResponse.data;

    if (currentUser == null) return;

    final String currentStatus = currentUser.status.value;
    final String currentDescription = currentUser.statusDescription;

    final String lastAppliedStatus = activeProfile.lastAppliedStatus?.apiValue ?? "";
    final String lastAppliedDescription = activeProfile.lastAppliedMessage ?? "";

    if (lastAppliedStatus.isNotEmpty &&
      (currentStatus != lastAppliedStatus || currentDescription != lastAppliedDescription)) {
        await statusRepo.setProfileActive(activeProfile.id!, false);
        _shutdown();
        return;
      }
    
    final context = await _buildStatusContext(currentUser);

    final localSocialRepo = await ref.read(localSocialRepositoryProvider.future);
    final automationRepo = await ref.read(automationRepositoryProvider.future);

    final evaluationUseCase = EvaluateStatusUseCase(
      matchers: [
        NumericConditionMatcher(),
        InstanceTypeMatcher(),
        FriendRoleMatcher(localSocialRepo)
      ],
      resolver: StatusTemplateResolver()
    );

    final coordinator = CoordinateStatusAutomationUseCase(
      statusRepository: statusRepo,
      automationRepository: automationRepo,
      evaluateStatusUseCase: evaluationUseCase,
    );

    final result = await coordinator.execute(
      activeProfile: activeProfile,
      currentContext: context,
    );

    result.fold(
      (failure) => {},
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