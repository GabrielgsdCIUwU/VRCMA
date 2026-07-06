import 'package:vrcma/domain/entities/automation/status_automation.dart';

abstract class IStatusRepository {
  Future<List<StatusProfile>> getStatusProfiles();
  Future<int> saveStatusProfile(StatusProfile profile);
  Future<void> deleteStatusProfile(int id);
  Future<void> setProfileActive(int id, bool isActive);
  Future<void> updateLastAppliedStatus(int profileId, StatusType status, String message);
}