import 'package:dio/dio.dart';
import 'package:vrcma/core/network/sanitizer/i_json_sanitizer_rule.dart';

/// Sanitizes `/auth/user` responses where VRChat omits unset `CurrentUser` fields.
///
/// Prevents `CheckedFromJsonException` in `vrchat_dart` when optional profile
/// attributes such as `bio`, `bioLinks`, or `userIcon` are omitted or null.
class CurrentUserSanitizerRule implements IJsonSanitizerRule {
  static const Map<String, dynamic> _defaultFieldValues = {
    'bio': '',
    'bioLinks': <String>[],
    'profilePicOverride': '',
    'profilePicOverrideThumbnail': '',
    'userIcon': '',
    'pronouns': '',
    'pronounsHistory': <String>[],
    'statusDescription': '',
    'homeLocation': '',
    'currentAvatar': '',
    'currentAvatarImageUrl': '',
    'currentAvatarThumbnailImageUrl': '',
    'currentAvatarTags': <String>[],
    'tags': <String>[],
    'pastDisplayNames': <dynamic>[],
    'friendGroupNames': <String>[],
    'friends': <String>[],
    'statusHistory': <String>[],
  };

  @override
  bool canHandle(RequestOptions options) {
    return options.method.toUpperCase() == 'GET' &&
        options.path.endsWith('/auth/user');
  }

  @override
  dynamic sanitize(dynamic data) {
    if (data is! Map<String, dynamic>) return data;
    if (_isTwoFactorChallenge(data)) return data;

    final sanitized = Map<String, dynamic>.from(data);
    for (final entry in _defaultFieldValues.entries) {
      sanitized[entry.key] ??= _copyDefaultValue(entry.value);
    }
    return sanitized;
  }

  bool _isTwoFactorChallenge(Map<String, dynamic> payload) {
    // Do not inject CurrentUser defaults into 2FA challenge payloads.
    return payload.containsKey('requiresTwoFactorAuth') ||
        !payload.containsKey('id');
  }

  dynamic _copyDefaultValue(dynamic value) {
    if (value is List<String>) return List<String>.from(value);
    if (value is List) return List<dynamic>.from(value);
    return value;
  }
}