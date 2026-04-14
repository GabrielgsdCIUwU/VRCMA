import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/data/repositories/automation_repository_imp.dart';
import 'package:vrcma/domain/usecases/automation/automation_processor.dart';
import 'package:vrcma/domain/usecases/automation/message_slot_manager.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/logs_provider.dart';

part 'automation_provider.g.dart';

@riverpod
class AutomationState extends _$AutomationState {
  @override
  void build() {
    ref.keepAlive();
    _init();
  }
  
  Future<void> _init() async {
    final api = await ref.watch(vrcApiProvider.future);
    api.streaming.start();
    
    final automationRepo = AutomationRepositoryImp(api);
    
    final processor = AutomationProcessor(
      automationRepository: automationRepo,
      localSocialRepository: await ref.watch(localSocialRepositoryProvider.future),
      profileRepository: await ref.watch(profileRepositoryProvider.future),
      logRepository: await ref.watch(logRepositoryProvider.future),
      slotManager: MessageSlotManager(
        messageRepository: await ref.watch(messageRepositoryProvider.future),
        automationRepository: automationRepo
      ),
      useCase: ProcessInvitationUseCase(
        roleExtractor: UserRoleExtractor(),
        ruleSorter: RuleSorter(),
        ruleEvaluator: RuleEvaluator(),
        defaultResolver: DefaultActionResolver(),
      ),
    );
    
    automationRepo.watchInvitations().listen((invitation) async {
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