import 'package:vrcma/domain/entities/automation/filter_profile.dart';

abstract class IProfileRepository {
  Future<List<FilterProfile>> getProfiles();
  Future<void> saveProfile(FilterProfile profile);
  Future<void> deleteProfile(int id);
  Future<void> setActiveProfile(int id);
}