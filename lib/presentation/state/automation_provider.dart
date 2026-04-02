import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/data/repositories/automation_repository_imp.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';
import 'package:vrcma/domain/usecases/automation/automation_processor.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:vrcma/presentation/state/logs_provider.dart';
import 'package:vrcma/presentation/state/profile_management_provider.dart';

part 'automation_provider.g.dart';

@riverpod
class AutomationState extends _$AutomationState {
  @override
  void build() {
    _init();
  }
  
  Future<void> _init() async {
    final api = await ref.watch(vrcApiProvider.future);
    
    final processor = AutomationProcessor(
      automationRepository: AutomationRepositoryImp(api),
      localSocialRepository: await ref.watch(localSocialRepositoryProvider.future),
      profileRepository: await ref.watch(profileRepositoryProvider.future),
      logRepository: await ref.watch(logRepositoryProvider.future),
      useCase: ProcessInvitationUseCase(
        roleExtractor: UserRoleExtractor(),
        ruleSorter: RuleSorter(),
        ruleEvaluator: RuleEvaluator(),
        defaultResolver: DefaultActionResolver(),
      ),
    );
    
    AutomationRepositoryImp(api).watchInvitations().listen((invitation) async {
      await processor.process(invitation);
      ref.invalidate(automationLogsProvider);
    });
  }
}