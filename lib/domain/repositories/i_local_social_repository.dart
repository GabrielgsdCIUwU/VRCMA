import 'package:vrcma/domain/entities/automation/filter_profile.dart';

abstract class ILocalSocialRepository {
  Future<List<Role>> getRolesForUser(String userId);
  Future<void> assignRoleToUser(String userId, int roleId);
  Future<void> removeRoleFromUser(String userId, int roleId);
  Future<List<Role>> getAllAvailableRoles();
  Future<int> createRole(String name);
  Future<void> deleteRole(int roleId);
  Future<int> getMemberCountForRole(int roleId);
  Future<List<String>> getUserIdsByRole(int roleId);
}
