import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';
import 'package:vrcma/domain/usecases/automation/process_friend_automations_use_case.dart';
import 'package:vrcma/presentation/state/friends_provider.dart';
import 'package:vrcma/presentation/state/role_management_provider.dart';
import 'package:vrcma/presentation/state/user_details_provider.dart';

part 'role_automation_provider.g.dart';

@riverpod
class RoleAutomationList extends _$RoleAutomationList {
  @override
  FutureOr<List<RoleAutomation>> build() async {
    final repo = await ref.watch(localSocialRepositoryProvider.future);
    return repo.getRoleAutomations();
  }

  Future<void> save(RoleAutomation automation) async {
    state = const AsyncLoading();
    final repo = await ref.read(localSocialRepositoryProvider.future);
    await repo.saveRoleAutomation(automation);
    
    final currentFriends = ref.read(friendsListProvider).value;
    
    if (currentFriends != null && currentFriends.isNotEmpty) {
      final useCase = ProcessFriendAutomationsUseCase(repo);
      await useCase.execute(currentFriends);
    }
    
    ref.invalidate(roleMemberCountProvider);
    ref.invalidate(userMetadataProvider);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    final repo = await ref.read(localSocialRepositoryProvider.future);
    await repo.deleteRoleAutomation(id);
    ref.invalidateSelf();
  }
}

@riverpod
class RoleAutomationEditor extends _$RoleAutomationEditor {
  @override
  RoleAutomation build(RoleAutomation? initial) {
    return initial ?? RoleAutomation(
      roles: [],
      trigger: AutomationTrigger.newFriend,
    );
  }

  bool get hasChanges => state != initial;

  bool get isValid {
    final hasRoles = state.roles.isNotEmpty;
    final validTrigger = state.trigger == AutomationTrigger.newFriend ||
        (state.trigger == AutomationTrigger.hasTag && state.targetValue != null);
    return hasRoles && validTrigger;
  }

  void updateTrigger(AutomationTrigger trigger) {
    state = RoleAutomation(
      id: state.id,
      roles: state.roles,
      trigger: trigger,
      targetValue: trigger == AutomationTrigger.hasTag ? state.targetValue : null,
    );
  }

  void setTargetValue(String tagId) {
    state = state.copyWith(targetValue: tagId);
  }

  void addRole(Role role) {
    if (!state.roles.contains(role)) {
      state = state.copyWith(roles: [...state.roles, role]);
    }
  }

  void removeRole(Role role) {
    state = state.copyWith(
      roles: state.roles.where((r) => r.id != role.id).toList()
    );
  }

  void saveAndClose() {
    if (!isValid) return;
    ref.read(roleAutomationListProvider.notifier).save(state);
  }
}