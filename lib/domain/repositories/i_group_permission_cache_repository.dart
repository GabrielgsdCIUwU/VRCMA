/// Interfaz para la gestión de caché local de permisos de grupos
abstract class IGroupPermissionCacheRepository {
  /// Retorna [true] si el usuario tiene permisos cacheados y la caché sigue siendo válida.
  Future<bool> hasValidCachedPermission(String userId, String groupId);

  /// Guarda en la base de datos que el usuario tiene permisos para el grupo.
  Future<void> savePermissionCache(String userId, String groupId);
}
