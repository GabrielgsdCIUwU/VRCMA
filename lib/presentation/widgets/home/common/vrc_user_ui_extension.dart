import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';

extension VrcUserUiExtension on VrcUser {
  bool get isTrulyOffline => location == 'offline' || status.toLowerCase() == 'offline';
  
  String get formattedLocation {
   if (isTrulyOffline) return 'Offline';
   if (location.isEmpty) return 'Active on Website';
   
   final instance = VrcInstance.parse(location);
   
   if (instance.isTraveling) return 'Traveling...';
   if (instance.isPrivate) return 'Private Instance';
   
   if (instance.isResolvableWorld) {
     return '${instance.accessTypeString} Instance (${instance.region})';
   }
   return location;
  }
}