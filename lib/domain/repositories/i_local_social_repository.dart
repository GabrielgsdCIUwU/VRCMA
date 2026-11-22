import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';

abstract class ILocalSocialRepository {
  Future<List<Role>> getRolesForUser(String userId);
  Future<void> assignRoleToUser(String userId, int roleId);
  Future<void> assignMultipleRoles(Map<String, Set<int>> userRoles);
  Future<void> removeRoleFromUser(String userId, int roleId);
  Future<List<Role>> getAllAvailableRoles();
  Future<int> createRole(String name);
  Future<void> deleteRole(int roleId);
  Future<int> getMemberCountForRole(int roleId);
  Future<List<String>> getUserIdsByRole(int roleId);
  Future<void> updateRoleName(int roleId, String newName);
  Future<void> syncRoleMembers(int roleId, Set<String> newUserIds);
  Future<List<RoleAutomation>> getRoleAutomations();
  Future<void> saveRoleAutomation(RoleAutomation automation);
  Future<void> deleteRoleAutomation(int automationId);
  Future<List<String>> getKnownUserIds();
  Future<void> saveKnownUsers(List<VrcUser> users);
}
