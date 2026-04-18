import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/presentation/state/profile_management_provider.dart';

part 'profile_editor_provider.g.dart';

@riverpod
class ProfileEditorNotifier extends _$ProfileEditorNotifier {
  late FilterProfile _initialProfile;
  
  @override
  FilterProfile build(FilterProfile profile) {
    _initialProfile = profile;
    return profile.copyWith(
      rules: List.from(profile.rules)..sort((a, b) => a.priority.compareTo(b.priority))
    );
  }
  
  bool get hasChanges {
    final nameChanged = state.name != _initialProfile.name;
    final rulesChanged = !const ListEquality().equals(state.rules, _initialProfile.rules);
    return nameChanged || rulesChanged;
  }
  
  void updateName(String name) {
    state = state.copyWith(name: name);
  }
  
  void updateRuleMessage(int index, CustomMessage? message) {
    final newRules = List<ProfileRule>.from(state.rules);
    newRules[index] = newRules[index].copyWith(message: message);
    state = state.copyWith(rules: newRules);
  }
  
  void updateRuleAction(int index, RuleAction action) {
    final newRules = List<ProfileRule>.from(state.rules);
    newRules[index] = newRules[index].copyWith(action: action);
    state = state.copyWith(rules: newRules);
  }
  
  void addRule(Role role) {
    final newRules = List<ProfileRule>.from(state.rules);
    newRules.add(ProfileRule(
      role: role,
      priority: newRules.length,
      action: RuleAction.accept,
    ));
    state = state.copyWith(rules: newRules);
  }
  
  void removeRule(int index) {
    final newRules = List<ProfileRule>.from(state.rules)..removeAt(index);
    state = state.copyWith(rules: newRules);
  }
  
  void reorderRules(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final newRules = List<ProfileRule>.from(state.rules);
    final item = newRules.removeAt(oldIndex);
    newRules.insert(newIndex, item);
    
    for (int i = 0; i < newRules.length; i++) {
      newRules[i] = newRules[i].copyWith(priority: i);
    }
    state = state.copyWith(rules: newRules);
  }
  
  void save() {
    ref.read(profileManagementProviderProvider.notifier).updateProfile(state);
  }
}