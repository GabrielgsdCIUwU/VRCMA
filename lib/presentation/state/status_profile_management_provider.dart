import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';

part 'status_profile_management_provider.g.dart';

@riverpod
class StatusProfileManagement extends _$StatusProfileManagement {
  @override
  FutureOr<List<StatusProfile>> build() async {
    final repo = await ref.watch(statusRepositoryProvider.future);
    return repo.getStatusProfiles();
  }

  Future<void> addProfile(String name) async {
    state = const AsyncLoading();
    final repo = await ref.read(statusRepositoryProvider.future);
    await repo.saveStatusProfile(StatusProfile(name: name, fallbackStatus: StatusType.active));
    ref.invalidateSelf();
  }

  Future<void> deleteProfile(int id) async {
    final repo = await ref.read(statusRepositoryProvider.future);
    await repo.deleteStatusProfile(id);
    ref.invalidateSelf();
  }

  Future<void> toggleProfileActive(StatusProfile profile) async {
    final repo = await ref.read(statusRepositoryProvider.future);
    await repo.setProfileActive(profile.id!, !profile.isActive);
    ref.invalidateSelf();
  }

  Future<void> updateProfile(StatusProfile profile) async {
    final repo = await ref.read(statusRepositoryProvider.future);
    await repo.saveStatusProfile(profile);
    ref.invalidateSelf();
  }
}