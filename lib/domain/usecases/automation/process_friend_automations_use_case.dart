import 'dart:isolate';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';

class ProcessFriendAutomationsUseCase {
  final ILocalSocialRepository _localSocialRepository;

  ProcessFriendAutomationsUseCase(this._localSocialRepository);

  Future<void> execute(List<VrcUser> apiFriends) async {
    final automations = await _localSocialRepository.getRoleAutomations();
    if (automations.isEmpty) {
      return _localSocialRepository.saveKnownUsers(apiFriends);
    }

    final knownUserSet = (await _localSocialRepository.getKnownUserIds()).toSet();

    final rolesToAssignMap = await Isolate.run(() => _computeRoles(
        apiFriends,
        automations,
        knownUserSet
    ));

    await _localSocialRepository.assignMultipleRoles(rolesToAssignMap);
    await _localSocialRepository.saveKnownUsers(apiFriends);
  }

  static Map<String, Set<int>> _computeRoles(
      List<VrcUser> friends,
      List<RoleAutomation> automations,
      Set<String> knownUsers) {

    final result = <String, Set<int>>{};
    final tagLookup = {for (final tag in VrcTag.allTags) tag.id: tag.name.toLowerCase()};

    for (final friend in friends) {
      final isNewFriend = !knownUsers.contains(friend.id);
      final allUserTags = {
        ...friend.tags.map((t) => t.toLowerCase()),
        ...friend.tags.map((t) => tagLookup[t]).whereType<String>(),
      };

      final rolesToAssign = <int>{};

      for (final rule in automations) {
        if ((rule.trigger == AutomationTrigger.newFriend && isNewFriend) ||
            (rule.trigger == AutomationTrigger.hasTag &&
                rule.targetValue != null &&
                allUserTags.contains(rule.targetValue!.toLowerCase()))) {
          rolesToAssign.addAll(rule.roles.map((r) => r.id));
        }
      }

      if (rolesToAssign.isNotEmpty) {
        result[friend.id] = rolesToAssign;
      }
    }
    return result;
  }
}