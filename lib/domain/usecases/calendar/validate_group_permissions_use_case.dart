import 'package:vrcma/domain/repositories/i_remote_calendar_repository.dart';

/// Checks if the host has administrative calendar permissions in the target VRChat group.
class ValidateGroupPermissionsUseCase {
  final IRemoteCalendarRepository _remoteCalendarRepo;

  ValidateGroupPermissionsUseCase(this._remoteCalendarRepo);

  Future<bool> execute({
    required String userId,
    required String groupId,
  }) async {
    return await _remoteCalendarRepo.verifyCreationPermissions(userId, groupId);
  }
}