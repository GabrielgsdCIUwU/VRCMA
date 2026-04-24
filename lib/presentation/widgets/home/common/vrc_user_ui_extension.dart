import 'package:vrcma/domain/entities/auth/vrc_user.dart';

extension VrcUserUiExtension on VrcUser {
  bool get isTrulyOffline => location == 'offline' || status.toLowerCase() == 'offline';
  
  String get formattedLocation {
    if (location.isEmpty || location == 'offline') return 'Offline';
    if (location == 'private') return 'Private Instance';
    
    if (location.startsWith('wrld_')) {
      if (location.contains('~private')) return 'Invite Only / Invite+';
      if (location.contains('~hidden')) return 'Friends+ Instance';
      if (location.contains('~friends')) return 'Friends Instance';
      return 'Public Instance';
    }
    return location;
  }
}