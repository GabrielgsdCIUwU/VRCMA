import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/entities/automation/vrc_tag.dart';
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
    final tagsChanged = !const ListEquality().equals(state.fallbackTags, _initialProfile.fallbackTags);
    final tagActionChanged = state.fallbackTagsAction != _initialProfile.fallbackTagsAction;
    return nameChanged || rulesChanged || tagsChanged || tagActionChanged;
  }
  
  void updateName(String name) {
    state = state.copyWith(name: name);
  }
  
  void updateRuleMessage(int index, CustomMessage? message, RuleMessageContext context) {
    final rule = state.rules[index];
    
    _validateMessageType(message, context, rule.action);
    
    final newRules = List<ProfileRule>.from(state.rules);
    newRules[index] = context.applyMessageToRule(rule, message);
    
    state = state.copyWith(rules: newRules);
  }
  
  void _validateMessageType(CustomMessage? message, RuleMessageContext context, RuleAction action) {
    if (message == null) return;
    
    final expectedType = context.getExpectedMessageType(action);
    
    if (message.type != expectedType) {
      throw ArgumentError(
        "Message must be of type '${expectedType.name}' for ${context.name} when action is ${action.name}."
      );
    }
  }
  
  void updateRuleAction(int index, RuleAction action) {
    final newRules = List<ProfileRule>.from(state.rules);
    final currentRule = newRules[index];
    
    if (currentRule.action != action) {
      newRules[index] = currentRule.copyWith(
        action: action,
        inviteResponseMessage: () => null,
        requestResponseMessage: () => null,
      );
    } else {
      newRules[index] = currentRule.copyWith(action: action);
    }
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
  
  void updateFallbackTagsAction(FallbackTagAction action) {
    if (action == FallbackTagAction.disabled) {
      state = state.copyWith(fallbackTagsAction: action, fallbackTags: []);
    } else {
      state = state.copyWith(fallbackTagsAction: action);
    }
  }
  
  void addFallbackTag(VrcTag tag) {
    if (!state.fallbackTags.contains(tag)) {
      final newTags = List<VrcTag>.from(state.fallbackTags)..add(tag);
      state = state.copyWith(fallbackTags: newTags);
    }
  }
  
  void removeFallbackTag(VrcTag tag) {
    final newTags = List<VrcTag>.from(state.fallbackTags)..remove(tag);
    state = state.copyWith(fallbackTags: newTags);
  } 
}

extension RuleMessageContextExtension on RuleMessageContext {
  VrcMessageType getExpectedMessageType(RuleAction action) {
    final isAccept = action == RuleAction.accept;
    
    switch (this) {
      case RuleMessageContext.inviteResponse:
        return isAccept ? VrcMessageType.invite : VrcMessageType.response;
      case RuleMessageContext.requestResponse:
        return isAccept ? VrcMessageType.invite : VrcMessageType.requestResponse;
    }
  }
  
  ProfileRule applyMessageToRule(ProfileRule rule, CustomMessage? message) {
    switch (this) {
      case RuleMessageContext.inviteResponse:
        return rule.copyWith(inviteResponseMessage: () => message);
      case RuleMessageContext.requestResponse:
        return rule.copyWith(requestResponseMessage: () => message);
    }
  }
}