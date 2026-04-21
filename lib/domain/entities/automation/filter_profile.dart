import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';

class Role extends Equatable {
  final int id;
  final String name;
  const Role({required this.id, required this.name});
  @override List<Object?> get props => [id, name];
}

enum RuleAction { accept, reject }
enum FallbackTagAction { disabled, accept, reject }

enum RuleMessageContext { inviteResponse, requestResponse}

class ProfileRule extends Equatable {
  final int? id;
  final Role role;
  final int priority;
  final RuleAction action;
  final int? fallbackGroup;
  final CustomMessage? inviteResponseMessage;
  final CustomMessage? requestResponseMessage;


  const ProfileRule({
    this.id,
    required this.role,
    required this.priority,
    required this.action,
    this.fallbackGroup,
    this.inviteResponseMessage,
    this.requestResponseMessage,
  });
  
  ProfileRule copyWith({
    int? id,
    Role? role,
    int? priority,
    RuleAction? action,
    int? fallbackGroup,
    CustomMessage? Function()? inviteResponseMessage,
    CustomMessage? Function()? requestResponseMessage,
  }) {
    return ProfileRule(
      id: id?? this.id,
      role: role ?? this.role,
      priority: priority ?? this.priority,
      action: action ?? this.action,
      fallbackGroup: fallbackGroup ?? this.fallbackGroup,
      inviteResponseMessage: inviteResponseMessage != null ? inviteResponseMessage() : this.inviteResponseMessage,
      requestResponseMessage: requestResponseMessage != null ? requestResponseMessage() : this.requestResponseMessage,
    );
  }

  @override List<Object?> get props => [id, role, priority, action, fallbackGroup, inviteResponseMessage, requestResponseMessage];
}

class FilterProfile extends Equatable{
  final int? id;
  final String name;
  final bool isActive;
  final List<ProfileRule> rules;
  final Role? defaultRole;
  final List<String> fallbackTags;
  final FallbackTagAction fallbackTagsAction;

  const FilterProfile({
    this.id,
    required this.name,
    this.isActive = false,
    this.rules = const [],
    this.defaultRole,
    this.fallbackTags = const [],
    this.fallbackTagsAction = FallbackTagAction.disabled,
  });
  
  FilterProfile copyWith({
    int? id,
    String? name,
    bool? isActive,
    List<ProfileRule>? rules,
    Role? defaultRole,
    List<String>? fallbackTags,
    FallbackTagAction? fallbackTagsAction,
  }) {
    return FilterProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      rules: rules ?? this.rules,
      defaultRole: defaultRole ?? this.defaultRole,
      fallbackTags: fallbackTags ?? this.fallbackTags,
      fallbackTagsAction: fallbackTagsAction ?? this.fallbackTagsAction,
    );
  }

  @override List<Object?> get props => [id, name, isActive, rules, defaultRole, fallbackTags, fallbackTagsAction];

}