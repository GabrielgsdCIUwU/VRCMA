import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/presentation/state/status_profile_management_provider.dart';

part 'status_profile_editor_provider.g.dart';

@riverpod
class StatusProfileEditorNotifier extends _$StatusProfileEditorNotifier {
  late StatusProfile _initialProfile;

  @override
  StatusProfile build(StatusProfile profile) {
    _initialProfile = profile;
    return profile.copyWith(
      rules: List.from(profile.rules)..sort((a, b) => a.priority.compareTo(b.priority)),
    );
  }

  bool get hasChanges {
    final nameChanged = state.name != _initialProfile.name;
    final fallbackChanged = state.fallbackStatus != _initialProfile.fallbackStatus;
    final templateChanged = state.fallbackTemplate != _initialProfile.fallbackTemplate;
    final rulesChanged = !const ListEquality().equals(state.rules, _initialProfile.rules);

    return nameChanged || fallbackChanged || templateChanged || rulesChanged;
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateFallbackStatus(StatusType status) {
    state = state.copyWith(fallbackStatus: status);
  }

  void updateFallbackTemplate(String template) {
    state = state.copyWith(fallbackTemplate: template);
  }

  void addRule(StatusRule rule) {
    final newRules = List<StatusRule>.from(state.rules);
    newRules.add(StatusRule(
      id: rule.id,
      priority: newRules.length,
      targetStatus: rule.targetStatus,
      messageTemplate: rule.messageTemplate,
      conditionType: rule.conditionType,
      operator: rule.operator,
      conditionValue: rule.conditionValue
    ));
    state = state.copyWith(rules: newRules);
  }

  void removeRule(int index) {
    final newRules = List<StatusRule>.from(state.rules)..removeAt(index);

    for (int i = 0; i < newRules.length; i++) {
      newRules[i] = _rebuildRuleWithPriority(newRules[i], i);
    }
    state = state.copyWith(rules: newRules);
  }

  void updateRule (int index, StatusRule rule) {
    final newRules = List<StatusRule>.from(state.rules);
    newRules[index] = rule;
    state = state.copyWith(rules: newRules);
  }

  void reorderRules(int oldIndex, int newIndex) {
    final newRules = List<StatusRule>.from(state.rules);
    final item = newRules.removeAt(oldIndex);
    newRules.insert(newIndex, item);

    for (int i = 0; i < newRules.length; i++) {
      newRules[i] = _rebuildRuleWithPriority(newRules[i], i);
    }
    state = state.copyWith(rules: newRules);
  }

  StatusRule _rebuildRuleWithPriority(StatusRule original, int priority) {
    return StatusRule(
      id: original.id,
      priority: priority,
      targetStatus: original.targetStatus,
      messageTemplate: original.messageTemplate,
      conditionType: original.conditionType,
      operator: original.operator,
      conditionValue: original.conditionValue,
    );
  }

  void save() {
    ref.read(statusProfileManagementProvider.notifier).updateProfile(state);
  }
}