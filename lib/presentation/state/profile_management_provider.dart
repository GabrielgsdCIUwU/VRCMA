import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';

part 'profile_management_provider.g.dart';

@riverpod
class ProfileManagementProvider extends _$ProfileManagementProvider {
  @override
  FutureOr<List<FilterProfile>> build() async {
      final repo = await ref.watch(profileRepositoryProvider.future);
      return repo.getProfiles();
  }
  
  Future<void> addProfile(String name) async {
    state = const AsyncLoading();
    final repo = await ref.read(profileRepositoryProvider.future);
    await repo.saveProfile(FilterProfile(name: name));
    ref.invalidateSelf();
  }
  
  Future<void> deleteProfile(int id) async {
    final repo = await ref.read(profileRepositoryProvider.future);
    await repo.deleteProfile(id);
    ref.invalidateSelf();
  }
  
  Future<void> toggleProfileActive(FilterProfile profile) async {
    final repo = await ref.read(profileRepositoryProvider.future);
    await repo.setProfileActiveStatus(profile.id!, !profile.isActive);
    ref.invalidateSelf();
  }
  
  Future<void> updateProfile(FilterProfile profile) async {
    final repo = await ref.read(profileRepositoryProvider.future);
    await repo.saveProfile(profile);
    ref.invalidateSelf();
  }
}