/// Interface for managing local caching of group permissions.
abstract class IGroupPermissionCacheRepository {
  /// Returns [true] if the user has cached permissions and the cache is still valid.
  Future<bool> hasValidCachedPermission(String userId, String groupId);

  /// Saves in the database that the user has permissions for the group.
  Future<void> savePermissionCache(String userId, String groupId);
}
