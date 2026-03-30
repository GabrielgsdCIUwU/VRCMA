import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/core/di/database_provider.dart';


part 'user_details_provider.g.dart';

@riverpod
class UserMetadataNotifier extends _$UserMetadataNotifier {
  @override
  FutureOr<List<Role>> build(String userId) async {
    final repo = await ref.watch(localSocialRepositoryProvider.future);
    return repo.getRolesForUser(userId);
  }
  
  Future<void> toggleRole(Role role, bool assigned) async {
    final repo = await ref.read(localSocialRepositoryProvider.future);
    if (assigned) {
      await repo.assignRoleToUser(userId, role.id);
    } else {
      await repo.removeRoleFromUser(userId, role.id);
    }
    ref.invalidateSelf();
  }
}