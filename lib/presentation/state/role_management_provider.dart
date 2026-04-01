import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/presentation/state/profile_management_provider.dart';
import 'package:vrcma/presentation/state/user_details_provider.dart';

part 'role_management_provider.g.dart';

@riverpod
class RoleManagement extends _$RoleManagement {
  @override
  FutureOr<List<Role>> build() async {
    final repo = await ref.watch(localSocialRepositoryProvider.future);
    return repo.getAllAvailableRoles();
  }
  
  Future<void> createRole(String name) async {
    state = const AsyncLoading();
    final repo = await ref.read(localSocialRepositoryProvider.future);
    await repo.createRole(name);
    ref.invalidateSelf();
  }
  
  Future<void> deleteRole(int id) async {
    final repo = await ref.read(localSocialRepositoryProvider.future);
    await repo.deleteRole(id);
    ref.invalidateSelf();
    ref.invalidate(profileManagementProviderProvider);
  }
  
  Future<void> updateRoleMembers(int roleId, Set<String> newUserIds) async {
    final repo = await ref.read(localSocialRepositoryProvider.future);
    final currentIdsInDb = await repo.getUserIdsByRole(roleId);
    
    for (final userId in currentIdsInDb) {
      if (!newUserIds.contains(userId)) {
        await repo.removeRoleFromUser(userId, roleId);
      }
    }
    
    for (final userId in newUserIds) {
      if (!currentIdsInDb.contains(userId)) {
        await repo.assignRoleToUser(userId, roleId);
      }
    }
    
    ref.invalidate(roleMemberCountProvider(roleId));
    ref.invalidateSelf();
  }
}

@riverpod
Future<int> roleMemberCount(Ref ref, int roleId) async {
  final repo = await ref.watch(localSocialRepositoryProvider.future);
  return repo.getMemberCountForRole(roleId);
}