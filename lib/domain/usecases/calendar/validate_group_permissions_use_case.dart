import 'package:vrcma/domain/repositories/i_group_permission_cache_repository.dart';
import 'package:vrcma/domain/repositories/i_remote_calendar_repository.dart';

/// Checks if the host has administrative calendar permissions in the target VRChat group.
class ValidateGroupPermissionsUseCase {
  final IRemoteCalendarRepository _remoteCalendarRepo;
  final IGroupPermissionCacheRepository _cacheRepo;

  ValidateGroupPermissionsUseCase(this._remoteCalendarRepo, this._cacheRepo);

  Future<bool> execute({
    required String userId,
    required String groupId,
  }) async {
    // Verificar primero en la caché
    final isCached = await _cacheRepo.hasValidCachedPermission(userId, groupId);
    if (isCached) return true;

    // Si no está en caché, llamamos a la API
    final hasPermission = await _remoteCalendarRepo.verifyCreationPermissions(userId, groupId);

    // Si tiene permisos, guardamos en caché
    if (hasPermission) {
      await _cacheRepo.savePermissionCache(userId, groupId);
    }

    return hasPermission;
  }
}